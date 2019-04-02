#!/bin/bash
#For Backup Mysql
#Date:xxxx-xx-xx
MYSQL_IP="127.0.0.1"
DOCKERNAME="docker_name"
USER="user"
MYSQL_BAKDIR="path_mysqlback"
MYSQL_ALL_DIR="path_allmysqlback"
MYSQL_DIR="path_mysqlback/`date +%Y%m%d`"
##定义函数
function CMD()
{
/data/kube/bin/docker exec -i ${DOCKERNAME} mysqlshow -u${USER} -h ${MYSQL_IP} |grep -Ev "Databases|information_schema|test|sys"|grep -v '\+'|awk '{print $2}'
return 0
}
function DEL()
{
find ${MYSQL_BAKDIR} -type d -name `date +"%Y%m%d" -d "-7 days"`|xargs rm -rf
return 0
}
function MAIL()
{
file=`ls ${MYSQL_DIR}/*.gz`
if [ $? -ne 0 ];then 
    /bin/python /root/mail.py "Mysql-yc Backup Complete" "Failed"
else 
    /bin/python /root/mail.py "Mysql-yc Backup Complete" "Success"
fi
return 0
}
function DUMP()
{
/data/kube/bin/docker exec -i ${DOCKERNAME} mysqldump -u${USER} -h ${MYSQL_IP} ${1}
return 0
}
              
if [ ! -d ${MYSQL_DIR} ];then
    mkdir ${MYSQL_DIR} -p
fi
##执行备份
/bin/python /root/mail.py "Mysql-yc Backup starting...." "`date`"
echo "###############mysql back start###############" >> /mysqlback.log
echo -e "`date`" >> /mysqlback.log
for i in `CMD`
do
    DUMP ${i}|gzip > ${MYSQL_DIR}/${i}_$(date +%F).sql.gz
    if [ ${?} -ne 0 ]; then
        echo "Mysql Backup ${i} Failed 备份命令执行异常!!!" >> /mysqlback.log 
    else
        echo "Mysql Backup ${i} Success" >> /mysqlback.log
    fi
done
echo -e "`date`" >> /mysqlback.log
echo "##############mysql back stop###############" >> /mysqlback.log
MAIL
DEL
##每周日全备
if [ ! -d ${MYSQL_ALL_DIR} ];then
    mkdir ${MYSQL_ALL_DIR} -p
fi
DATE=`date +%w`
if [ ${DATE} -eq 0 ];then
    DUMP --all-databases | gzip > ${MYSQL_ALL_DIR}/$(date +%F)_mysqlbak.sql.gz
else
    exit 0
fi
