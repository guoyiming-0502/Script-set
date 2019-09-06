#!/bin/bash
#author:guoyaqiang
#date:2019/09/06
if [ ! -n "${1}" ] || [ ! -n "${2}" ];then
    echo -e "\033[32m [Info] \033[0m 至少需要两个参数:1.(指定namespace)2.(指定appname)3.(可选logs|yaml|shell)"
    echo -e "\033[33m [Error] \033[0m Quit, Lack of parameters!"
    exit 1
else
    cmds=`kubectl get po -n ${1}|grep -v "NAME"|awk '{print $1}'`
    for i in $cmds;do
        poname=`echo ${i} | grep ${2}`
        if [ ${?} -eq 0 ];then
            echo -e "\033[32m [Info] \033[0m Podname:$poname"
            break
        fi
    done
    if [ -n "${3}" ];then
        if [ ${3} == "logs" ];then
            kubectl logs -f $poname -n ${1}
        elif [ ${3} == "shell" ];then
            kubectl exec $poname -it -n ${1} sh
        elif [ ${3} == "yaml" ];then
            kubectl get po $poname -n ${1} -o yaml
        else
            echo -e "\033[33m [Error] \033[0m Parameters undefined!"
        fi
    else
        exit 1
    fi
fi

