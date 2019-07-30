#!/bin/bash
HOST="nw.hseduyun.net 8001"
LOCAL_DIR="/data/mysqlbackup"
username="dongsheng"
passwd="123qwe"
DATEDIR=`date +%Y%m%d`
LOGDIR="/data/ftpupload-logs"
if [ ! -d ${LOCAL_DIR}/wbl/${DATEDIR} ];then
    echo ${LOCAL_DIR}/wbl/${DATEDIR}
    mkdir -p ${LOCAL_DIR}/wbl/${DATEDIR}
fi
if [ $? -eq 0 ];then
    scp 192.168.0.38:/data/mysqlback/${DATEDIR}/*.gz ${LOCAL_DIR}/wbl/${DATEDIR}/
fi
echo " " > ${LOGDIR}/wbl-ftp.log
echo "
open ${HOST}
user ${username} ${passwd}
binary
lcd ${LOCAL_DIR}/wbl/${DATEDIR}/
mkdir wbl
cd wbl
mkdir ${DATEDIR}
cd ${DATEDIR}
prompt
mput *.gz
close
bye
"  |ftp -v -n |tee ${LOGDIR}/wbl-ftp.log

if [ -s ${LOGDIR}/wbl-ftp.log ];then
  SEARCH=`grep 'Ok to send data' ${LOGDIR}/wbl-ftp.log`

  if [ $? -eq 0 ];then
  curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=4d6e1917-549e-438a-bfb3-72914f927168' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": { "content": "万柏林环境数据异地备份成功!!!"}}'
  else
  curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=4d6e1917-549e-438a-bfb3-72914f927168' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": { "content": "万柏林环境数据备份异常,请检查日志!!!"}}'
  fi
  ERRORS=`grep 'Not connected.' ${LOGDIR}/wbl-ftp.log`
  if [ $? -eq 0 ];then
  curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=4d6e1917-549e-438a-bfb3-72914f927168' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": { "content": "ftp服务器异常!!!"}}'
  exit 1
  fi
fi

if [ -d /data/mysqlbackup/wbl/${DATEDIR} ];then
       rm -rf /data/mysqlbackup/wbl/${DATEDIR}
fi
