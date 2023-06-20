#!/bin/bash


repo_names=(wheeljackWeb wheeljackServer wheeljackDataAnalyser wheeljackMonitor wheeljackMesgChn wheeljackSorter wheeljackDataAnalyserExt)

##### 修改mac地址
macAddr=$(sudo lshw -c network | grep serial | head -n 1 | cut -f 2-7 -d ":")
NEW_MACADDR="$macAddr"
#每台机器需要修改不同的域名
NEW_subdomain="XXXXX"
#远程端口,18200至18300划给紫天使用
NEW_remote_port=18297

# 修改.env文件
sudo sed -i "s/SERVER_MACADDR=.*/SERVER_MACADDR=${NEW_MACADDR}/g" cmp.env
for i in ${!repo_names[@]}
do
  repo_name=${repo_names[$i]}
  if [ -d $repo_name ];then
     cp ./cmp.env $repo_name/.env
     echo "${repo_name}"
  fi
done

#修改ngrok.cfg文件
cfg="wheeljackServer/src/scripts/ngrok.cfg"
sudo sed -i 's/subdomain: .*/subdomain: '$NEW_subdomain'/' $cfg
sudo sed -i 's/remote_port: NGROK_SSH_PORT/remote_port: '$NEW_remote_port'/' $cfg
echo "Successfully modified the ngrok.cfg"

#修改ngrok.sh
ngroksh="wheeljackServer/src/scripts/ngrok.sh"
sudo sed -i 's/ssh be \&/ssh \&/g' $ngroksh
echo "Successfully modified the ngrok.sh"

#修改ic-tester.local
ictester_local="wheeljackServer/src/scripts/ic-tester.local"
sudo sed -i 's|var/www|home/ictester/service|g' $ictester_local
echo "Successfully modified the ic-tester.local"

#修改frpc.ini文件
frpc="/etc/frp/frpc.ini"
sudo sed -i "s/^user =.*/user = ${NEW_subdomain}/" $frpc
sudo sed -i "s/^subdomain =.*/subdomain = ${NEW_subdomain}/" $frpc
echo "Successfully modified the frpc.ini"
sudo service frpc restart
pm2 restart all