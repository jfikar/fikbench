#!/bin/bash
KERNEL=linux-5.8.tar.xz
OLDPATH=$PATH
export MALLOC_CHECK_="0"

if [ -z "${RUNS}" ]; then
	RUNS=10
fi

if [ -z "${PROGRESS}" ]; then
	echo -e "Runs: \t" $RUNS
fi

if [ ! -d downloads ]; then
	mkdir downloads
fi

TIMING_FILE=$(mktemp)


if [ -x /usr/sbin/dmidecode ]; then
	CORES=$(sudo dmidecode -t processor | grep "Core Count" | awk '{ print $3 }')
	THREADS=$(sudo dmidecode -t processor | grep "Thread Count" | awk '{ print $3 }')
else
	THREADS=$(OMP_NUM_THREADS= nproc)
fi

if [ -z "${JOBS}" ]; then
        JOBS=$(OMP_NUM_THREADS= nproc)
fi


#https://github.com/fearside/ProgressBar/
# Author : Teddy Skarin
# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
function ProgressBar {
# Process data
if [ -z "${PROGRESS}" ]; then
        let _progress=(${1}*100/${2}*100)/100
        let _done=(${_progress}*4)/10
        let _left=40-$_done
# Build progressbar string lengths
        _done=$(printf "%${_done}s")
        _left=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress: [${_done// /#}${_left// /-}] ${_progress}%%"
fi
}

function SwitchTo {

if [ -f /usr/bin/systemctl ];
then
        if [ ${1} == "performance" ]; then
                sudo systemctl stop cron.service >/dev/null
        else
                sudo systemctl start cron.service >/dev/null
        fi
fi

if [ -f /etc/init.d/dcron ];
then
        if [ ${1} == "performance" ]; then
                sudo /etc/init.d/dcron stop >/dev/null
        else
                sudo /etc/init.d/dcron start >/dev/null
        fi
fi

if [ -f /etc/init.d/cronie ];
then
	if [ ${1} == "performance" ]; then
                sudo /etc/init.d/cronie stop >/dev/null
        else
		sudo /etc/init.d/cronie start >/dev/null
        fi
fi



if [ ${1} == "performance" ]; then
                echo 0 | sudo tee /proc/sys/kernel/randomize_va_space >/dev/null
		echo 1 | sudo tee /proc/sys/kernel/perf_event_max_sample_rate >/dev/null
		cat /dev/null > "${TIMING_FILE}"

else
                echo 1 | sudo tee /proc/sys/kernel/randomize_va_space >/dev/null
		echo 100000 | sudo tee /proc/sys/kernel/perf_event_max_sample_rate >/dev/null
		#echo "Best time:"
		if [ -z "${PROGRESS}" ]; then
			ProgressBar 100 100
			echo " "
			echo -e "\t real \t \t user"
		fi
		echo -n -e '\t'
		#best time
		#echo -n $(grep real ${TIMING_FILE} | awk '{print $2}' | sort -n | head -1)
		#echo -n -e '\t'
		#echo    $(grep user ${TIMING_FILE} | awk '{print $2}' | sort -n | head -1)
		#average+-std
		grep real ${TIMING_FILE} | awk '{   sumX=sumX+$2 ; sumX2+=(($2)^2)} END { printf " %.3f+-%.3f\t", sumX/(NR), sqrt((sumX2-sumX^2/NR)/(NR-1)/NR)}'
		grep user ${TIMING_FILE} | awk '{   sumX=sumX+$2 ; sumX2+=(($2)^2)} END { printf " %.3f+-%.3f\n", sumX/(NR), sqrt((sumX2-sumX^2/NR)/(NR-1)/NR)}'
		#cat ${TIMING_FILE}
		rm ${TIMING_FILE}
		export PATH=$OLDPATH
fi

if [ -f /usr/sbin/tmpreaper ];
then
        echo "Cleaning temp ....." > /dev/null
        #sudo /etc/cron.daily/tmpreaper >/dev/null
        #echo "Cleaning temp done."
fi


if [ -f /bin/systemd-tmpfiles ];
then
        echo "Cleaning temp ....." > /dev/null
        #sudo systemd-tmpfiles --remove >/dev/null
        #echo "Cleaning temp done."
fi



#clear caches, free RAM
sync
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

#echo " "
if [ -f /proc/acpi/ibm/fan ]; then
	if [ ${1} == "performance" ]; then
		echo level disengaged | sudo tee /proc/acpi/ibm/fan > /dev/null
	else
		echo level auto | sudo tee /proc/acpi/ibm/fan > /dev/null
	fi
fi

if [ -f /usr/sbin/x86_energy_perf_policy ]; then
	if [ ${1} == "performance" ]; then
		sudo /usr/sbin/x86_energy_perf_policy performance
	else
		sudo /usr/sbin/x86_energy_perf_policy normal
	fi
fi

if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]; then
	if ! grep -q ${1} /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors; then
    		set "powersave"
	fi
	if  grep -q ${1} /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors; then
		for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor;do
        		echo ${1} | sudo tee ${i} > /dev/null
		done
		if [ -z "${PROGRESS}" ]; then
			echo " "
			printf "Switching to governor: "
			cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
		fi
	fi
#else
#	if [ -z "${PROGRESS}" ]; then
#		echo "No governors available, no switching."
#	fi
fi

#echo " "
}

function CheckReturnCode {
if [[ $? -ne 0 ]]; then
	echo " "
	echo " "
	echo "***********************************"
	echo "Executable failed, abort test loop!"
	echo "***********************************"
        rm ${TIMING_FILE} 2>/dev/null
        export PATH=$OLDPATH
	exit 1
fi
}
