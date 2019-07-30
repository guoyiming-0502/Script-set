#!/bin/bash
#当前端口
file=/etc/sysconfig/iptables
num=`cat ${file} |grep -v "\-1"|grep "PREROUTING"|sed '1d'|awk '{print $10}'|wc -l`
old=`cat ${file}|grep -v "\-1"|grep "PREROUTING"|sed '1d'|awk '{print $10}'`
unum=`sort -k2n $file|grep -v "\-1"|grep "PREROUTING"|sed '1d'|awk '{print $10}'|uniq|wc -l`
#前一次生成的端口组成数组
oldp=()
c=0
for i in $old
do
oldp[${c}]=${i}
let c++
done
#生成随机端口
function rand(){  
        min=$1  
        max=$(($2-$min+1))  
        num=$(date +%s%N)  
        echo $(($num%$max+$min))
        return 0
}
#新生成的端口组成数组并进行替换
        newp=()
        b=0
        for a in $(seq 1 ${num})
        do
        rnd=$(rand 20000 60000)
        newp[${b}]=${rnd}
        let b++
        done
length=0
for i in ${oldp[*]}
do
sed -i "s/${oldp[$length]}/${newp[$length]}/g" $file &>/dev/null
let length++
done
#判断端口是否有重复,如果有继续使用上次生成的端口
if [ ${num} -eq ${unum} ];then
    MAIL
else
    python /root/mail.py "New iptables rules Port repeat" "Not changed"
    sed -i "s/${newp[$length]}/${oldp[$length]}/g" $file &>/dev/null
fi
function MAIL()
{
/etc/init.d/iptables reload && /etc/init.d/iptables save
if [ $? -ne 0 ];then
    python /root/mail.py "New iptables rules" "Execution fail"
else
    python /root/mail.py "New iptables rules" "Execution success"
fi
echo "<meta charset="utf-8"><pre>" > /hskj/openresty/nginx/html/portlist.html
echo -e "规则生成时间: `date`   6小时后更新" >> /hskj/openresty/nginx/html/portlist.html
python scan_rules.py >> /hskj/openresty/nginx/html/portlist.html
return 0
}
MAIL
