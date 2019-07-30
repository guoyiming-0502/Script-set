#!/bin/bash
# pod restart status
pd=$1
filetmp=/tmp/k8s_status.log
pos=`ssh root@192.168.0.16 "kubectl get pod -n yc" | /bin/awk '{print $1,$4}'> ${filetmp}`
case ${pd} in
wisdomsaas-platform-deploy)
                output=$(awk '/wisdomsaas-platform/{print $2}' ${filetmp} | sort -rn | sed -n '1p')
                   echo $output
                ;;
#passport-deploy)
#                output=$(awk '/passport-deploy/{print $2}' ${filetmp} | sort -rn | sed -n '1p')
#                   echo $output
#                ;;
#resource-deploy)
#                output=$(awk '/resource-deploy/{print $2}' ${filetmp} | sort -rn | sed -n '1p')
#                   echo $output
#                ;;
#dubbox-live-web-deploy)
#                output=$(awk '/dubbox-live-web-deploy/{print $2}' ${filetmp} | sort -rn | sed -n '1p')
#                   echo $output
#                ;;
esac
