# fikbench
Simple shell scripts for benchmarking

This work is inspired by [Phoronix Test Suite](https://github.com/phoronix-test-suite/phoronix-test-suite) and alo uses its files, but I wanted something simpler. The main goal is to compare different compile optimizations available in [Gentoo](https://gentoo.org/), especially using [LTO optimizations](https://github.com/InBetweenNames/gentooLTO). But it can also be used for general purpose benchmarking.

The env variable RUNS contains number of succesive timed runs of the benchmarked command. The average and standard deviation of time real (wall) and user (cpu) time are the displayed. The lower the better. If RUNS is not defined, it equals to 10. The ratio of user/real time is approximately equal to the number of used CPU cores.

The env variable PROGRESS controlls, if the individual benchmarks display a progress bar. If it is unset, progress bar is displayed. When set to a value, e.g. PROGRESS=0, no progress bar is displayed as it is the case for the main script `fikbench`.

## How to run
Do `chmod +x fikbench scripts/*`. Execute all benchmarks by using the supplied script `./fikbench`. Edit the script to exclude specific benchmarks.
Or you can execute the individual benchmarks one by one in the `scripts` folder just by invoking them `scripts/foobench`.

The benchmarks try to stop cron daemons, set the CPU governor to performance, flush caches, set the fan on IBM/Lenovo notebooks to max RPM etc. before the testing and reset them after each benchmark. For that the user runnign benchmarks needs `sudo` without password, which is considered dangerous. You can also run benchmarks without `sudo`.

The testing takes place in `/tmp` directory. It is advisable to have `/tmp` in RAM using tmpfs and having enough free space to compile the Linux kernel (actually around 1.6GB).

All the needed files are automatically downloaded into `downloads` folder using `wget` (if you don't already have them).

## Benchmarks

The 28 benchmarks can be divided into 8 groups:

### 1. shell benchmarks
- **bashbench**, **ashbench** (shell in `busybox`), **dashbench**: 5M loop of a simple test

### 2. calculation benchmarks
- **bcbench**: calculate and verify the number pi using `bc` to 5k places
- **javabench**: runtime of Java of [Scimark 2.0](https://math.nist.gov/scimark2/download_java.html) with the `-large` switch
- **lammpsbench**: simple Molecular Dynamics simulation of a Cu crystal in [LAMMPS](https://lammps.sandia.gov/)

### 3. compression benchmarks
- **lzopbench**, **lz4bench**, **gzipbench**, **pigzbench** (parallel version of `gzip`), **zstdbench**: compression of the Linux kernel source code, default settings
- **xzbench**, **lrzipbench**: the same, but only the first 150MB of the Linux kernel source code, because it is slower
- **zopflibench** (gzip compatible but ultra slow), **pigzzopflibench** (the same, but parallel): the same, but only the first 20MB of the Linux kernel source code, because it even slower

### 4. compilation benchmarks
- **gccbench**: compilation of Linux kernel defconfig
- **ccachebench**: the same but using `ccache` to cache the compiled results, the first run is discarded
- **clangbench**: compilation of Linux kernel defconfig, some settings are manually switched to allow clang compilation, the same settings are also switched in gccbench and ccachebench so one can compare them

### 5. gentoo utils benchmarks
- **eixbench**: time for `sudo eix-update`
- **emergebench**: essentialy a python benchmark, tests time to evaluate `emerge -uDvpU --with-bdeps=y @world`, so essentially the time will vary, taken from [@telans](https://github.com/InBetweenNames/gentooLTO/issues/552#issuecomment-671772521)

### 6. sound benchmarks
- **normalizebench**: time to normalize a wav file
- **flacbench**, **oggbench**, **lamebench**: convert to flac, ogg, mp3

### 7. video benchmarks
- **mencoderbench**: time to convert video to AVC mpeg4

### 8. picture benchmarks
- **jpegtransbench**: time to convert several jpeg images by jpegtrans with no parameters, `-optimize`, `-progressive`, `-arithmetic` and `-arithmetic -progressive`
- **optipngbench**: time to optimize one png picture with `optipng -o7 -zm1-9`
- **zopflipngbench**: the same png picture optimized by `zopflipng -m --lossy_8bit --lossy_transparent`

## Needed software

- The software needed for Linux kernel compilation: **gcc**, **clang**, **bison**, **flex**, **ccache**, ... for Debian/Ubuntu: `sudo apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev clang ccache`

- Compression utilities: `sudo apt-get lzop lz4 zstd pigz lrzip zopfli`

- Gentoo users can see the needed packages in the `fikbench` file.


## Sample output
Intel Xeon E3-1265L V2, 2.50GHz
```
**************************************************************************************************************
Sun Aug 30 07:45:14 PM CEST 2020
sys-devel/gcc-9.3.0-r1: total(1616), inaccessible(0), size(188934812)
sys-devel/gcc-10.2.0-r1: total(1616), inaccessible(0), size(207916420)
sys-devel/clang-10.0.0: total(919), inaccessible(0), size(152452984)
sys-devel/lld-10.0.0: total(11), inaccessible(0), size(4637900)
sys-libs/glibc-2.31-r6: total(1833), inaccessible(0), size(61649484)
dev-java/icedtea-3.16.0: total(343), inaccessible(0), size(101606611)
sys-apps/busybox-1.31.1-r2: total(62), inaccessible(0), size(2439154)
app-shells/bash-5.0_p18: total(41), inaccessible(0), size(2533090)
app-shells/dash-0.5.11.1: total(10), inaccessible(0), size(229698)
sys-devel/bc-1.07.1-r3: total(19), inaccessible(0), size(325842)
app-arch/gzip-1.10: total(44), inaccessible(0), size(339709)
app-arch/pigz-2.4-r1: total(13), inaccessible(0), size(251856)
app-portage/eix-0.34.4: total(48), inaccessible(0), size(1707535)
dev-lang/python-2.7.18-r100: total(4177), inaccessible(0), size(80070572)
dev-lang/python-3.7.8-r2: total(6616), inaccessible(0), size(102544841)
dev-lang/python-3.8.5: total(6833), inaccessible(0), size(106951222)
media-libs/flac-1.3.3: total(66), inaccessible(0), size(1753044)
media-sound/lame-3.100-r2: total(40), inaccessible(0), size(1118071)
app-arch/xz-utils-5.2.5: total(104), inaccessible(0), size(1525980)
app-arch/zopfli-1.0.3: total(25), inaccessible(0), size(422648)
media-video/mplayer-1.3.0-r6: total(114), inaccessible(0), size(5511541)
media-sound/vorbis-tools-1.4.0-r5: total(23), inaccessible(0), size(417040)
media-sound/normalize-0.7.7-r1: total(16), inaccessible(0), size(235234)
media-libs/libjpeg-turbo-2.0.5-r1: total(157), inaccessible(0), size(2324944)
sci-physics/lammps-20200303: total(251), inaccessible(0), size(147457799)
dev-libs/lzo-2.10: total(32), inaccessible(0), size(431139)
app-arch/lzop-1.04: total(13), inaccessible(0), size(213041)
app-arch/lz4-1.9.2: total(26), inaccessible(0), size(581250)
dev-util/ccache-3.7.11: total(18), inaccessible(0), size(334183)
media-libs/libpng-1.6.37: total(44), inaccessible(0), size(1528536)
sys-libs/zlib-1.2.11-r2: total(50), inaccessible(0), size(1455521)
media-gfx/optipng-0.7.7: total(17), inaccessible(0), size(280858)
app-arch/zstd-1.4.5: total(32), inaccessible(0), size(2974790)

Bench:                   real            user
-------------------------------------------------------
Bash:                    12.369+-0.017   12.189+-0.016
Ash:                     8.208+-0.015    8.396+-0.013
Dash:                    4.472+-0.010    4.438+-0.010
Bc:                      16.764+-0.011   16.752+-0.001
Java:                    27.484+-0.089   27.620+-0.067
Lammps:                  22.069+-0.217   172.583+-0.128
Lzop:                    2.422+-0.008    2.236+-0.007
Lz4:                     2.321+-0.008    1.986+-0.007
Gzip:                    25.607+-0.013   25.467+-0.014
Pigz:                    5.472+-0.008    43.141+-0.033
Zstd:                    1.744+-0.020    11.255+-0.093
Xz:                      13.280+-0.020   72.583+-0.086
Lrzip:                   12.597+-0.051   67.083+-0.105
Zopfli:                  21.823+-0.015   21.789+-0.014
Pigz.zopfli:             6.348+-0.008    49.153+-0.016
Gcc:                     281.756+-0.453  2047.508+-0.452
Ccache:                  23.567+-3.722   72.308+-1.441
Clang:                   704.925+-0.490  5447.957+-0.629
Eix:                     2.291+-0.613    1.539+-0.005
Emerge:                  20.137+-2.266   18.347+-0.685
Normalize:               0.240+-0.009    0.197+-0.004
Flac:                    7.572+-0.123    7.398+-0.005
Ogg:                     7.925+-0.131    7.780+-0.002
Lame:                    14.085+-0.130   13.940+-0.003
Mencoder:                22.345+-0.202   22.119+-0.005
Jpegtran:                23.133+-0.007   22.565+-0.016
Optipng:                 44.846+-0.013   44.826+-0.004
Zopfli.png:              14.085+-0.023   14.059+-0.002
Elapsed time 27652 seconds
**************************************************************************************************************
```
