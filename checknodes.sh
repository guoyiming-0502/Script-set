CHECK=`kubectl get nodes | grep -v "NAME" | awk '{print $2}'`
CKINFO=`kubectl get nodes | grep -v "NAME" | grep "Ready,SchedulingDisabled" | awk '{print $1,$2}'| sed -e 's/ /-/g'`
ERROR="NotReady"
for i in ${CHECK};do
  if [ ${i} == "Ready,SchedulingDisabled" ];then
    echo ${CKINFO}
    curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=XXXXXXXXXXXXXX' -H 'Content-Type: application/json' -d '{"msgtype": "text","text": { "content": "kubernets节点异常:'${CKINFO}'"}}'
  fi
done
