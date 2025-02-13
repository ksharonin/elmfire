#!/bin/bash

. ./99-post_funcs.sh --source-only

STARTSEC=`date +%s`

progress_message "Start new episode"

SCRATCH=./scratch
OUTPUTS=./outputs
rm -f -r $SCRATCH $OUTPUTS 
mkdir -p $SCRATCH $OUTPUTS

#cp 01-run.sh $OUTPUTS/01-run.sh
cp elmfire.data $OUTPUTS/elmfire.data

ELMFIRE_VER=${ELMFIRE_VER:-2024.0916}
ELMFIRE_INSTALL_DIR=${ELMFIRE_INSTALL_DIR:-$ELMFIRE_BASE_DIR/build/linux/bin}
ELMFIRE=$ELMFIRE_INSTALL_DIR/elmfire_$ELMFIRE_VER
ELMFIRE_DEBUG=$ELMFIRE_INSTALL_DIR/elmfire_debug_$ELMFIRE_VER

progress_message "Launching ELMFIRE"

SOCKETS=`lscpu | grep 'Socket(s)' | cut -d: -f2 | xargs`
CORES_PER_SOCKET=`lscpu | grep 'Core(s) per socket' | cut -d: -f2 | xargs`
let "NP = SOCKETS * CORES_PER_SOCKET"

ELMFIRE_NUM_MPI_PROCESSES=`cat /proc/cpuinfo | grep "cpu cores" | cut -d: -f2 | tail -n 1 | xargs`
ELMFIRE_HOSTS=`printf "$(hostname),%.0s" {1..64}`

# GDB DEBUGGING
# dir /home/katrinasharonin/Downloads/elmfire/build/source
# gdb --args $ELMFIRE_DEBUG elmfire.data 

# REGULAR
# $ELMFIRE elmfire.data

# MEMORY PROFILING
# valgrind --tool=cachegrind --cachegrind-out-file=/home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/cache_analysis2.out $ELMFIRE_DEBUG elmfire.data
# cg_annotate /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/cache_analysis2.out > /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/cache_analysis2.txt


# GNU PROFILING
# $ELMFIRE_DEBUG elmfire.data 
# gprof $ELMFIRE_DEBUG gmon.out > /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/analysis.txt

# PERF PROFILE
# sudo sysctl -w kernel.perf_event_paranoid=-1

perf record -o /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/perf.data -g $ELMFIRE_DEBUG elmfire.data 
perf report -n -i /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/perf.data > /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/perf_analysis.txt
perf annotate -l -s __elmfire_spread_rate_MOD_umd_ucb_bldg_spread -i /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/perf.data > /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/umd_ucb_target_analysis.txt

# perf report -i /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/perf.data > /home/katrinasharonin/Downloads/elmfire/tutorials/for-kat/perf_report.txt

# HINTS
# addr2line -e /home/katrinasharonin/Downloads/elmfire/build/linux/bin/elmfire_debug_2024.0916 0x2b3b4
# To show func name + file + line
# addr2line -fe /home/katrinasharonin/Downloads/elmfire/build/linux/bin/elmfire_debug_2024.0916 0x2b968
# print at sp offset in gdb
# x/40w $sp+180 

# mpi runs
#-host $ELMFIRE_HOSTS
# mpirun --mca btl tcp,self --oversubscribe -np 6 $ELMFIRE elmfire.data >& elmfire.out


ENDSEC=`date +%s`
let "RUNTIME = ENDSEC - STARTSEC"
progress_message "ELMFIRE run is complete"
echo "Simulation wall clock time:  $RUNTIME s"




exit 0
