#/bin/bash
#Date:2019年8月9日
#script for env onekey deploy
Font_prefix="\033[32m" && Error_prefix="\033[31m" && background_prefix="\033[42;37m" && Error_background_prefix="\033[41;37m" && Font_suffix="\033[0m"
echo -e "${Font_prefix}[信息]${Font_suffix} 一键式系统部署."
init(){
#时区同步
#yum install ntpdate -y
#/sbin/ntpdate pool.ntp.org > /dev/null 2>&1
DATE=`date`
#IP截取
IP=`ip a | grep -w "inet" | grep -Ev "127.0.0.1|172*" | awk '{print $2}' | cut -d "/" -f1`
IPS=`ip a | grep -w "inet" | grep -Ev "127.0.0.1|172*" | awk '{print $2}' | cut -d "/" -f1 | wc -l`
if [ ${IPS} != 2 ];then
    echo -e "${Error_prefix}[错误]${Font_suffix} IP地址异常,请检查是否有多个IP或未配置."
    exit 1
else
    break
fi
#关闭防火墙selinux
#systemctl stop firewalld.service && \
#systemctl disable firewalld.service > /dev/null 2>&1 && \
#setenforce 0 > /dev/null 2>&1 && sed -i 's/enforcing/disabled/g' /etc/selinux/configure
#内核升级
SYSTEM=`cat /etc/centos-release | cut -d " " -f1,3,4`
KERNEL=`uname -r | cut -d "-" -f1`


#内核参数优化


#安装Prometheus



#输出deploy env
echo -e "${Font_prefix}[信息]${Font_suffix} 系统初始化完成."
echo -e "${Font_prefix}[信息]${Font_suffix} 系统时间: $DATE"
echo -e "${Font_prefix}[信息]${Font_suffix} 操作系统: $SYSTEM "
echo -e "${Font_prefix}[信息]${Font_suffix} 系统内核: $KERNEL" 
echo -e "${Font_prefix}[信息]${Font_suffix} 本机地址: $IP"
}
init
####
deploy_docker(){
which docker > /dev/null 2>&1
if [ $? -eq 0 ];then
    Dversion=`docker --version`
    echo -e "${Error_prefix}[信息]${Font_suffix} 检测到 Docker 已安装,版本为: $Dversion"
    break
else
    echo "docker"
    echo -e "${Font_prefix}[信息]${Font_suffix} Docker 已安装成功,版本为: $Dversion"
fi
}
##docker 交互
echo -e "${Font_prefix}[提示]${Font_suffix} 是否安装Docker,10s后将默认安装. (y/n)?"
read -t 10 -e -p "(默认: y):" dk
if [[ ${dk} == "y" ]] || [ ! -n "${dk}" ];then
    deploy_docker
else
    echo "已取消..." && break
fi
####
deploy_k8s(){
which kubectl > /dev/null 2>&1
if [ $? -eq 0 ];then
    Kversion=`kubectl version | grep -E "Server Version"|cut -d ":" -f5 | cut -d "," -f1`
    echo -e  "${Error_prefix}[信息]${Font_suffix} 检测到 Kubernetes 已安装,版本为: $Kversion"
    break
else
#    curl -s https://getcaddy.com | bash -s personal http.cache,http.geoip,http.git,http.grpc
#    caddy delete
    echo -e "${Font_prefix}[提示]${Font_suffix} 需要输入本机root密码"
    read -e -p "(请输入):" pd
    if [ -n ${pd} ];then
        yum update && yum install -y python git python-pip expect
        pip install pip --upgrade -i https://mirrors.aliyun.com/pypi/simple/
        pip install ansible==2.6.12 netaddr==0.7.19 -i https://mirrors.aliyun.com/pypi/simple/
        ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519
        expect << EOF
            spawn ssh-copy-id ${IP}
            expect "(yes/no)?" {send "yes\r"}
            expect "password:" {send "${pd}\r"}
            expect "#" {send "exit\r"}
EOF
       cd /data
       curl -C- -fLO --retry 3 https://github.com/easzlab/kubeasz/releases/tag/2.0.2/easzup
       chmod +x ./easzup && \
       ./easzup -D && \
       cd /etc/ansible && \
       cp example/hosts.multi-node hosts
       ansible all -m ping
       ansible-playbook 90.setup.yml
       if [ $? -eq 0 ];then
           echo -e  "${Font_prefix}[信息]${Font_suffix} Kubernetes 安装成功,版本为: $Kversion"
       else
           echo -e "${Error_prefix}[错误]${Font_suffix} Kubernetes安装失败" && exit 1
       fi
    else
        break
    fi
fi
}
#k8s 交互
echo -e "${Font_prefix}[提示]${Font_suffix} 是否部署k8s,10s内未确认将默认不安装.(y/n)?"
read -t 10 -e -p "(默认: n):" ks
if [[ ${ks} == "n" ]] || [ ! -n "${ks}" ];then
    echo "已取消..." && break
else
    deploy_k8s
fi

####
deploy_openresty(){
which openresty > /dev/null 2>&1
if [ $? -eq 0 ];then
    Nversion=`openresty -v`
    echo -e  "${Error_prefix}[信息]${Font_suffix} 检测到 openresty 已安装,版本为: $Nversion"
    break
else
    mkdir -p /data/openresty && cd /data
    wget https://openresty.org/download/openresty-1.15.8.1.tar.gz
    yum -y install readline-devel pcre-devel openssl-devel gcc perl curl
    useradd -s /sbin/nologin -M nginx
    cd /data/openresty-1.15.8.1
    cd /data/openresty-1.15.8.1
    ./configure --prefix=/data/openresty --group=nginx --user=nginx --with-http_ssl_module --with-http_sub_module --with-http_gzip_static_module --with-pcre --with-http_realip_module --with-http_addition_module --with-http_stub_status_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_random_index_module --with-http_secure_link_module --with-http_auth_request_module --with-stream --with-stream_ssl_module --with-stream --with-stream_ssl_module
    gmake & gmake install
    ln -s /data/openresty/bin/openresty /usr/bin/openresty 
    echo -e "${Font_prefix}[提示]${Font_suffix} openresty 安装成功,安装目录/data/openresty,已加入环境变量/usr/bin/openresty"
fi
}

#openresty 交互
echo -e "${Font_prefix}[提示]${Font_suffix} 是否部署openresty,10s内未确认将默认不安装.(y/n)?"
read -t 10 -e -p "(默认: n):" op
if [[ ${op} == "n" ]] || [ ! -n "${op}" ];then
    echo "已取消..." && break
else
    deploy_openresty
fi
####
deploy_Prometheus(){
echo "Prometheus"
}
#Prometheus 交互
echo -e "${Font_prefix}[提示]${Font_suffix} 是否部署Prometheus,10s内未确认将默认不安装.(y/n)?"
read -t 10 -e -p "(默认: n):" ps
if [[ ${op} == "n" ]] || [ ! -n "${op}" ];then
    echo "已取消..." && break
else
    deploy_Prometheus
fi
