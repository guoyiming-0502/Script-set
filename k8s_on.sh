#/bin/bash
#k8s 一键启动

if [ $# -lt 1 ];then
    echo -e "\033[36m k8s一键启动,请指定命名空间 \033[0m"
    exit 1
elif [ ${1} == "test" ] || [ ${1} == "demo" ];then
    frist=`kubectl get deploy -n ${1} | awk '{print $1}' | grep -v "NAME" | grep -E "registercenter"`
    two=`kubectl get deploy -n ${1} | awk '{print $1}' | grep -Ev "NAME|appgateway-deploy" | grep -E "gateway"`
    three=`kubectl get deploy -n ${1} | awk '{print $1}' | grep "rpc"`
    four=`kubectl get deploy -n ${1} | awk '{print $1}' | grep -Ev "NAME|rpc|gateway|registercenter"`
    kubectl scale deployment --replicas=1  -n ${1} ${frist}
    sleep 5 
    kubectl scale deployment --replicas=1  -n ${1} ${two}
    sleep 5
    for i in ${three};do
        kubectl scale deployment --replicas=1  -n ${1} ${i}
    done
    sleep 10
    for j in ${four};do
        kubectl scale deployment --replicas=1 -n ${1} ${j}
    done
else
    three=`kubectl get deploy -n ${1} | awk '{print $1}' | grep "rpc"`
    four=`kubectl get deploy -n ${1} | awk '{print $1}' | grep -Ev "NAME|rpc|gateway|registercenter"`
    for k in ${three};do
        kubectl scale deployment --replicas=1 -n ${1} ${k}
    done
    sleep 10
    for g in ${four};do
        kubectl scale deployment --replicas=1 -n ${1} ${g}
    done
fi
