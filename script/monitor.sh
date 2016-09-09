#! /bin/bash


BIN_DIR=$(dirname `readlink -f "$0"`)
WORK_DIR=$(dirname $BIN_DIR)

source ${WORK_DIR}/conf/dynamic.conf

REDIS_STATUS=-1
REDIS_PID=`cat ${WORK_DIR}/data/redis.pid`

REDIS_INFO=`${WORK_DIR}/bin/redis-cli -h localhost -p ${PORT} info | sed -e 's/\r//g'`
CPU_INFO=`nice -19 top -n 1 -b -p ${REDIS_PID} | grep "^${REDIS_PID} "`
MAX_MEMORY=`${WORK_DIR}/bin/redis-cli -h localhost -p ${PORT} config get maxmemory | tr '\n' ' ' | awk '{print $2}' `

if [ -z "${CPU_INFO}" ]
then
    CPUUSED=-1
else
    CPUUSED=`echo ${CPU_INFO} | awk '{print $9}'`
fi

if [ -z "${REDIS_INFO}" ]; then
    echo RedisStatus:-1
    echo MemoryUsed:-1
    echo MemoryUsedPeak:-1
    echo CpuUsed:${CPUUSED}
    echo BDEOF
    exit 1
else
    ROLE=`echo "$REDIS_INFO" | grep "role" | awk -F ":" '{print $2}'`
    MEMUSED=`echo "$REDIS_INFO" | grep "used_memory:" | awk -F ":" '{print $2}'`
    MEMUSEDPEAK=`echo "$REDIS_INFO" | grep "used_memory_peak:" | awk -F ":" '{print $2}'`
    MEMUSED_RATIO=`echo ${MEMUSED} ${MAX_MEMORY} | awk '{printf("%.2f",$1*100/$2)}'`
    MEMUSEDPEAK_RATIO=`echo ${MEMUSEDPEAK} ${MAX_MEMORY} | awk '{printf("%.2f",$1*100/$2)}'`
    SERVEROPS=`echo "$REDIS_INFO" | grep "instantaneous_ops_per_sec:" | awk -F ":" '{print $2}'`
    if [ "${ROLE}" == "master" ]; then
        echo RedisStatus:1
    elif [ "${ROLE}" == "slave" ]; then
        echo RedisStatus:2
    else
        echo RedisStatus:3
        echo MemoryUsed:-1
        echo MemoryUsedPeak:-1
        echo ServerOps:-1
        echo CpuUsed:${CPUUSED}
        echo BDEOF
        exit 1
    fi
    echo MemoryUsed:${MEMUSED_RATIO}
    echo MemoryUsedPeak:${MEMUSEDPEAK_RATIO}
    echo ServerOps:${SERVEROPS}
    echo CpuUsed:${CPUUSED}
    echo BDEOF
    exit 0
fi


