#/bin/bash
dm=`kubectl get deploy -n demo|grep -v "NAME"|grep -E "interface|resource-wbl|passport|passport-wbl|wisdomsaas-platform|wisdomsaas-zycms|wisdomsaas-cms|resource"|awk '{print $1}'`
wt=`kubectl get deploy -n test|grep -v "NAME"|grep -E "registercenter|interface|gateway|resource-wbl|passport|passport-wbl|wisdomsaas-platform|wisdomsaas-zycms|wisdomsaas-cms|resource"|awk '{print $1}'`
yt=`kubectl get deploy -n yctest|grep -v "NAME"|grep -E "registercenter|interface|gateway|resource-wbl|passport|passport-wbl|wisdomsaas-platform|wisdomsaas-zycms|wisdomsaas-cms|resource"|awk '{print $1}'`
read -p "请输入命名空间,按q退出当前脚本:  " names
if [ ${names} == 'q' ];then
    exit 1
elif [ ${names} == 'demo' ];then
    kubectl scale deployment --replicas=1 -n ${names} registercenter-deploy && kubectl scale deployment --replicas=1  -n ${names} gateway
    for i in ${dm};do
        kubectl scale deployment --replicas=1  -n ${names} ${i}
    done
elif [ ${names} == 'test' ];then
    kubectl scale deployment --replicas=1  -n ${names} registercenter-deploy && kubectl scale deployment --replicas=1  -n ${names} gateway
    for j in ${wt};do
        kubectl scale deployment --replicas=1 -n ${names} ${j}
    done
elif [ ${names} == 'yctest' ];then
    for k in ${yt};do
        kubectl scale deployment --replicas=1 -n ${names} ${k}
    done
else
    echo "输入不合法!!!"
    exit 1
fi









kubectl scale deployment --replicas=1  -n ${1} ${2}-deploy
