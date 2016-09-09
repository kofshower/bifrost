#! /bin/bash

BIN_DIR=$(dirname `readlink -f "$0"`)
WORK_DIR=$(dirname $BIN_DIR)
DATA_DIR=${WORK_DIR}/data

LINE_NUM=`ls ${DATA_DIR}/temp-*.rdb | wc -l`

source ${WORK_DIR}/conf/dynamic.conf

${WORK_DIR}/bin/redis-cli -h localhost -p ${PORT} BGSAVE

while true
do
	TEMP_LINE_NUM=`ls ${DATA_DIR}/temp-*.rdb | wc -l`
	if [ "${TEMP_LINE_NUM}" != "${LINE_NUM}" ]
	then
		sleep 1
	else
		echo Bg Save end.
		exit 0
	fi
done
