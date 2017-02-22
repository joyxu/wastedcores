#!/bin/bash

COMPILER=hhvm
INPUT=input/$1/$1.prof
PID=$3

generate_sched_profiler_graphs_all_parallel()
{
    mkdir -p output/${6}

    I=0

    START_PADDED=`printf "%03d" $START`
    FILE_BASENAME=$(basename $INPUT)
    FILE_ROOT=${FILE_BASENAME%.*}

    cat $INPUT |                                                               \
        ${COMPILER}                                                            \
        ./parse_rows_sched_profiler.php                                        \
        output/${6}/${5}_standard.png                                               \
        $3 300000 -1 $7 standard $1 $2 $4 $PID &

    cat $INPUT |                                                               \
        ${COMPILER}                                                            \
        ./parse_rows_sched_profiler.php                                        \
        output/${6}/${5}_load.png                                                   \
        $3 300000 -1 $7 load $1 $2 $4 $PID &
}

# Generic runqueue and load graphs
generate_sched_profiler_graphs_all_parallel 0 -1 10 nothing generic $1 $2

# Considered wakeups for core zero
generate_sched_profiler_graphs_all_parallel 201 0 10 nothing wakeups $1 $2

generate_sched_profiler_graphs_all_parallel 231 0 10 nothing ctx $1 $2

# Graph with threads movements and "overloaded wakeups"
generate_sched_profiler_graphs_all_parallel 0 -1 10 arrows arrows $1 $2
generate_sched_profiler_graphs_all_parallel 0 -1 10 bad_wakeups               \
                                                     overloaded_wakeups $1 $2

cp input/$1/$1.* output/$1/

wait

