#!/bin/bash
config_files=( "cortex" "kibana" "kuma" "misp" "shuffle" "thehive" )

for i in "${!config_files[@]}";do
    if [ -f /etc/nginx/templates/"${config_files[i]}".conf ];then
        envsubst '$CORTEX_URL,$KIBANA_URL,$KUMA_URL,$MISP_URL,$SHUFFLE_URL,$THEHIVE_URL' < /etc/nginx/templates/${config_files[i]}.conf > /etc/nginx/conf.d/${config_files[i]}.conf
    fi
done
if [ $? -eq 0 ]; then nginx -g 'daemon off;';fi
