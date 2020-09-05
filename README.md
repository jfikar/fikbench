# fikbench
Simple shell scripts for benchmarking

This work is inspired by [Phoronix Test Suite](https://github.com/phoronix-test-suite/phoronix-test-suite) and alo uses its files, but I wanted something simpler. The main goal is to compare different compile optimizations available in [Gentoo](https://gentoo.org/), especially using [LTO optimizations](https://github.com/InBetweenNames/gentooLTO). But it can also be used for general purpose benchmarking.

The env variable RUNS contains number of succesive timed runs of the benchmarked command. The average and standard deviation of time real (wall) and user (cpu) time are the displayed. The lower the better. If RUNS is not defined, it equals to 10. The ratio of user/real time is approximately equal to the number of used CPU cores.

The env variable PROGRESS controlls, if the individual benchmarks display a progress bar. If it is unset, progress bar is displayed. When set to a value, e.g. PROGRESS=0, no progress bar is displayed as it is the case for the main script `fikbench`.

## How to run
Do `chmod +x fikbench scripts/*`. Execute all benchmarks by using the supplied script `./fikbench`. Edit the script to exclude specific benchmarks.
Or you can execute the individual benchmarks one by one in the `scripts` folder just by invoking them `scripts/foobench`.

The benchmarks try to stop cron daemons, set the CPU governor to performance, flush caches, set the fan on IBM/Lenovo notebooks to max RPM etc. before the testing and reset them after each benchmark. For that the user runnign benchmarks needs `sudo` without password, which is considered dangerous. You can also run benchmarks without `sudo`.

The testing takes place in `/tmp` directory. It is advisable to have `/tmp` in RAM using tmpfs and having enough free space to compile the Linux kernel (actually around 1.6GB on x86_64, but 6.2GB on arm64).

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
Intel Xeon E3-1265L V2, 2.50GHz, RUNS=20
```
**************************************************************************************************************
Sun Aug 30 07:45:14 PM CEST 2020
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
Zstd:                    1.744+-0.020    11.255+-0.093
Gzip:                    25.607+-0.013   25.467+-0.014
Pigz:                    5.472+-0.008    43.141+-0.033
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
Raspberry Pi4, 8GB RAM, arm_freq=2000, over_voltage=5, hdmi_enable_4kp60=1 (core_freq=550), RUNS=10
```
**************************************************************************************************************
Fri 04 Sep 2020 02:38:58 PM CEST
Bench:                   real            user
-------------------------------------------------------
Bash:                    35.700+-0.074   35.286+-0.073
Ash:                     20.898+-0.056   18.978+-0.058
Dash:                    12.555+-0.037   12.492+-0.041
Bc:                      33.508+-0.008   33.505+-0.008
Java:                    28.493+-0.500   29.174+-0.490
Lammps:                  79.006+-0.318   310.503+-0.482
Lzop:                    5.294+-0.066    4.145+-0.028
Lz4:                     5.599+-0.041    4.292+-0.024
Zstd:                    21.685+-0.060   77.685+-0.239
Gzip:                    65.812+-0.177   64.819+-0.185
Pigz:                    21.062+-0.092   78.852+-0.310
Zopfli:                  52.228+-0.105   52.094+-0.105
Pigz.zopfli:             18.919+-0.028   74.810+-0.111
Xz:                      55.987+-0.036   184.000+-0.043
Lrzip:                   54.345+-0.361   178.967+-0.457
Gcc:                   3400.364+-5.554   11959.620+-5.766
Normalize:               0.938+-0.006    0.606+-0.012
Flac:                    40.167+-0.036   40.007+-0.022
Ogg:                     14.748+-0.068   14.669+-0.063
Lame:                    29.981+-0.196   29.656+-0.032
Mencoder:                97.755+-0.246   97.378+-0.060
Optipng:                 94.055+-0.072   94.026+-0.071
Zopfli.png:              31.993+-0.016   31.957+-0.014
```
