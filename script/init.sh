#! /bin/bash

BIN_DIR=$(dirname `readlink -f "$0"`)
WORK_DIR=$(dirname $BIN_DIR)
DATA_DIR=${WORK_DIR}/data
CONF_DIR=${WORK_DIR}/conf
ZK_GETTER=${WORK_DIR}/bin/zk_getter
GET_SERVERS=${BIN_DIR}/get_servers

source ${CONF_DIR}/dynamic.conf
source ${CONF_DIR}/init.conf

${ZK_GETTER} -z ${ZKHOSTS} -p ${MPPATH}_mapping > ${CONF_DIR}/channel_mapping.txt
if [ $? -ne 0 ]
then
    echo Get Channel Mapping info failed. >&2
    exit 1
fi

echo '' >> ${CONF_DIR}/channel_mapping.txt

LOCAL_SERVER_HOST=`hostname`":${PORT}"
LOCAL_SERVER_IP=`hostname -i`":${PORT}"

REGION_NAME=`grep "\b${LOCAL_SERVER_HOST}\b" ${CONF_DIR}/channel_mapping.txt | awk '{print $1}'`
if [ -z ${REGION_NAME} ]
then
    REGION_NAME=`grep "\b${LOCAL_SERVER_IP}\b" ${CONF_DIR}/channel_mapping.txt | awk '{print $1}'`
fi

if [ -z ${REGION_NAME} ]
then
    echo FATAL Get RegionName Failed. >&2
    exit 1
fi

sed -i "s/^REGION_NAME=.*/REGION_NAME=${REGION_NAME}/" ${CONF_DIR}/dynamic.conf

cd ${WORK_DIR}
mkdir -p ${DISK_PATH}
ln -s ${DISK_PATH} data
cd -
