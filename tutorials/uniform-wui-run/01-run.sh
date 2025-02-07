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


#ELMFIRE_VER=${ELMFIRE_VER:-2024.0103}
ELMFIRE_VER=${ELMFIRE_VER:-2024.0916}
ELMFIRE_INSTALL_DIR=${ELMFIRE_INSTALL_DIR:-$ELMFIRE_BASE_DIR/build/linux/bin}
ELMFIRE=$ELMFIRE_INSTALL_DIR/elmfire_$ELMFIRE_VER
ELMFIRE_DEBUG=$ELMFIRE_INSTALL_DIR/elmfire_debug_$ELMFIRE_VER

SOCKETS=`lscpu | grep 'Socket(s)' | cut -d: -f2 | xargs`
CORES_PER_SOCKET=`lscpu | grep 'Core(s) per socket' | cut -d: -f2 | xargs`
let "NP = SOCKETS * CORES_PER_SOCKET"

ELMFIRE_NUM_MPI_PROCESSES=`cat /proc/cpuinfo | grep "cpu cores" | cut -d: -f2 | tail -n 1 | xargs`
ELMFIRE_HOSTS=`printf "$(hostname),%.0s" {1..64}`

#-host $ELMFIRE_HOSTS
# dir /home/katrinasharonin/Downloads/elmfire/build/source
#gdb --args $ELMFIRE_DEBUG elmfire.data 

# $ELMFIRE elmfire.data

$ELMFIRE_DEBUG elmfire.data 
gprof $ELMFIRE_DEBUG gmon.out > /home/katrinasharonin/Downloads/elmfire/tutorials/uniform-wui-run/analysis.txt


ENDSEC=`date +%s`
let "RUNTIME = ENDSEC - STARTSEC"
echo "Simulation wall clock time:  $RUNTIME s"

exit 0
