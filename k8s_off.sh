#!/bin/bash
# k8s 一键缩容
ES=`kubectl get deployment -n ${1}|awk -F [' ']+ '{print $1}'|grep -v "NAME"`
if [ $# -lt 1 ];then
    echo -e "\033[36m k8s一键缩容,请指定命名空间. \033[0m"
    exit 1
else
    for i in ${ES};do 
        kubectl scale deployment --replicas=0  -n ${1} $i
    done
fi
