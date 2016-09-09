#! /bin/bash

function print_help()
{
	echo Redis Control Help
	echo "  help      Print help"
	echo "  start     Start redis"
	echo "  stop      Stop  redis"
	echo "  check     check redis"
	echo "  cg_start  start redis with cgroup"
	echo "  cg_attach attach redis process with cgroup"
}

BIN_DIR=$(dirname `readlink -f "$0"`)
WORK_DIR=$(dirname $BIN_DIR)
DATA_DIR=${WORK_DIR}/data
CONF_DIR=${WORK_DIR}/conf
ZK_GETTER=${WORK_DIR}/bin/zk_getter
GET_SERVERS=${BIN_DIR}/get_servers

action=$1

if [ "$action" == "help" ]; then
	print_help
	exit 0
fi


if [ "$action" == "start" ]; then

	# check data dir is a soft link
	if [ ! -L ${DATA_DIR} ]; then
		echo Data dir not exits or not a soft link create it first!
		exit 1
	fi


	if [ -e ${WORK_DIR}/data/redis.pid ]; then
		kill -0 $(cat ${WORK_DIR}/data/redis.pid) &>/dev/null
		if [ $? -eq 0 ];then
			echo Redis is still runing! >&2
			exit 1
		fi
	fi

	source ${WORK_DIR}/conf/dynamic.conf	
	if [ $? -ne 0 ]; then
		echo Souce dynamic.conf failed! >&2
		exit 1
	fi
	
	if [ -z ${PORT} ]; then
		echo Need port to start redis! >&2
		exit 1
	fi

    if [ -z ${MPPATH} ]
    then
        echo Need MPPATH to get channle info! >&2
        exit 1
    fi

    if [ -z ${ZKHOSTS} ]
    then
        echo Need ZKHOSTS to get channle info! >&2
        exit 1
    fi

    if [ -z ${REGION_NAME} ]
    then
        echo Get RegionName Failed. >&2
        exit 1
    fi

    REGION_INFO=`${GET_SERVERS} -p ${MPPATH} -z ${ZKHOSTS} | grep "${REGION_NAME} "`
    if [ $? -ne 0 ] || [ -z "${REGION_INFO}" ]
    then
        echo Get Region info failed.
        exit 1
    fi

    LOCAL_SERVER_HOST=`hostname`":${PORT}"
    LOCAL_SERVER_IP=`hostname -i`":${PORT}"

    REGION_MASTER=`echo ${REGION_INFO} | awk '{print $2}'`

    if [ -z ${REGION_MASTER} ]
    then
        echo Get REGION_MASTER failed. >&2
        exit 1
    fi


    if [ -n ${REGION_MASTER} ]
    then
        REGION_MASTER_HOST=`echo ${REGION_MASTER} | awk -F':' '{print $1}'`
        REGION_MASTER_PORT=`echo ${REGION_MASTER} | awk -F':' '{print $2}'`
        if [ "${REGION_MASTER}" != "${LOCAL_SERVER_HOST}" ] && [ "${REGION_MASTER}" != "${LOCAL_SERVER_IP}" ]
        then
            SLAVEOF=${REGION_MASTER_HOST}
            MASTER_PORT=${REGION_MASTER_PORT}
            echo Start as a slave of ${REGION_MASTER_HOST}:${REGION_MASTER_PORT}
        fi
    fi

	REDIS_CONF=${WORK_DIR}/conf/redis.conf
	if [ -e ${REDIS_CONF} ]; then
		rm -rf ${WORK_DIR}/conf/redis.conf
	fi

	touch ${REDIS_CONF}
	echo port ${PORT} >> ${REDIS_CONF}
		
	if [[ -n ${SLAVEOF} ]]; then
		echo slaveof $SLAVEOF $MASTER_PORT >> ${REDIS_CONF}
	fi

	PROC_PATH=${WORK_DIR}/bin/${PROC_NAME}

	echo logfile ${WORK_DIR}/log/redis.log >> ${REDIS_CONF}
	echo pidfile ${WORK_DIR}/data/redis.pid >> ${REDIS_CONF}
	echo dbfilename ${WORK_DIR}/data/dump.rdb >> ${REDIS_CONF}
	echo appendfilename ${WORK_DIR}/data/appendonly.aof >> ${REDIS_CONF}
	echo dir ${WORK_DIR}/data >> $REDIS_CONF

	cat ${WORK_DIR}/conf/static.conf >> ${REDIS_CONF}
	${PROC_PATH} $REDIS_CONF
	sleep 1

	kill -0 $(cat ${WORK_DIR}/data/redis.pid) &>/dev/null
	if [ $? -eq 0 ];then
		echo Redis start succ!
	else
		echo Redis start failed!
		exit 1
	fi

	exit 0;
fi

if [ "$action" == "stop" ]; then
	REDIS_PID=${WORK_DIR}/data/redis.pid 
	if [ -e ${WORK_DIR}/data/redis.pid ]; then
		kill $(cat ${REDIS_PID}) &>/dev/null
		echo kill redis.
		exit 0
	fi
	echo PID file not exist kill nothing!
	exit 1
fi

if [ "$action" == "check" ]; then
	source ${WORK_DIR}/conf/dynamic.conf
	REDIS_PID=${WORK_DIR}/data/redis.pid
	HOST_NAME=`hostname`
	kill -0 $(cat ${REDIS_PID})
	if [ $? -eq 0 ];then
		echo ${HOST_NAME}:${PORT} process exist
		exit 0
	else
		echo ${HOST_NAME}:${PORT} process not exist
		exit 1
	fi

fi

if [ "$action" == "cg_start" ]; then
	source ${WORK_DIR}/conf/cgroup.conf

	# check data dir is a soft link
	if [ ! -L ${DATA_DIR} ]; then
		echo Data dir not exits or not a soft link create it first!
		exit 1
	fi


	if [ -e ${WORK_DIR}/data/redis.pid ]; then
		kill -0 $(cat ${WORK_DIR}/data/redis.pid) &>/dev/null
		if [ $? -eq 0 ];then
			echo Redis is still runing! >&2
			exit 1
		fi
	fi

	source ${WORK_DIR}/conf/dynamic.conf	
	if [ $? -ne 0 ]; then
		echo Souce dynamic.conf failed! >&2
		exit 1
	fi
	
	if [ -z ${PORT} ]; then
		echo Need port to start redis! >&2
		exit 1
	fi

    if [ -z ${MPPATH} ]
    then
        echo Need MPPATH to get channle info! >&2
        exit 1
    fi

    if [ -z ${ZKHOSTS} ]
    then
        echo Need ZKHOSTS to get channle info! >&2
        exit 1
    fi

    if [ -z ${REGION_NAME} ]
    then
        echo Get RegionName Failed. >&2
        exit 1
    fi

    REGION_INFO=`${GET_SERVERS} -p ${MPPATH} -z ${ZKHOSTS} | grep "${REGION_NAME} "`
    if [ $? -ne 0 ] || [ -z "${REGION_INFO}" ]
    then
        echo Get Region info failed.
        exit 1
    fi

    LOCAL_SERVER_HOST=`hostname`":${PORT}"
    LOCAL_SERVER_IP=`hostname -i`":${PORT}"

    REGION_MASTER=`echo ${REGION_INFO} | awk '{print $2}'`

    if [ -z ${REGION_MASTER} ]
    then
        echo Get REGION_MASTER failed. >&2
        exit 1
    fi


    if [ -n ${REGION_MASTER} ]
    then
        REGION_MASTER_HOST=`echo ${REGION_MASTER} | awk -F':' '{print $1}'`
        REGION_MASTER_PORT=`echo ${REGION_MASTER} | awk -F':' '{print $2}'`
        if [ "${REGION_MASTER}" != "${LOCAL_SERVER_HOST}" ] && [ "${REGION_MASTER}" != "${LOCAL_SERVER_IP}" ]
        then
            SLAVEOF=${REGION_MASTER_HOST}
            MASTER_PORT=${REGION_MASTER_PORT}
            echo Start as a slave of ${REGION_MASTER_HOST}:${REGION_MASTER_PORT}
        elif
            echo Start as a master
        fi
    fi

	REDIS_CONF=${WORK_DIR}/conf/redis.conf
	if [ -e ${REDIS_CONF} ]; then
		rm -rf ${WORK_DIR}/conf/redis.conf
	fi

	touch ${REDIS_CONF}
	echo port ${PORT} >> ${REDIS_CONF}
		
	if [[ -n ${SLAVEOF} ]]; then
		echo slaveof $SLAVEOF $MASTER_PORT >> ${REDIS_CONF}
	fi

	PROC_PATH=${WORK_DIR}/bin/${PROC_NAME}

	echo logfile ${WORK_DIR}/log/redis.log >> ${REDIS_CONF}
	echo pidfile ${WORK_DIR}/data/redis.pid >> ${REDIS_CONF}
	echo dbfilename ${WORK_DIR}/data/dump.rdb >> ${REDIS_CONF}
	echo appendfilename ${WORK_DIR}/data/appendonly.aof >> ${REDIS_CONF}
	echo dir ${WORK_DIR}/data >> $REDIS_CONF

	cat ${WORK_DIR}/conf/static.conf >> ${REDIS_CONF}

	cgexec -N ${CG_GROUP} ${PROC_PATH} $REDIS_CONF
	sleep 3

	kill -0 $(cat ${WORK_DIR}/data/redis.pid) &>/dev/null
	if [ $? -eq 0 ];then
		echo Redis start succ!
	else
		echo Redis start failed!
		exit 1
	fi

	exit 0;
fi


if [ "$action" == "cg_attach" ]; then
	source ${WORK_DIR}/conf/cgroup.conf
	REDIS_PID=${WORK_DIR}/data/redis.pid

	if [ -e ${REDIS_PID} ]
	then
		PID=`cat ${REDIS_PID}`
		kill -0 ${PID}
		if [ $? -eq 0 ]
		then
			cgattach -N ${CG_GROUP} ${PID}
			exit 0
		else
			echo process not exist
			exit 1
		fi
	else
		echo PID file not exist!
		exit 1
	fi
fi

echo unknow action [$action]
print_help
exit 1
