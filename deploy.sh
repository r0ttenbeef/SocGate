#!/bin/bash
# Author: r0ttenbeef
# Install packages, Configure the host and deploy the containers via docker-compose
# Compitable with ubuntu servers only
source ${PWD}/.env

err='[\e[0;31mx\e[0;0m]'
prog='[\e[0;34m*\e[0;0m]'
ok='[\e[0;32m+\e[0;0m]'

install_pkgs() {
    DESTINATION=/usr/local/bin/docker-compose
    packages=( "docker" "docker.io" "jq" "wget" "git" "openssl" )
    echo -e "${prog}Updating apt repositories"
    apt-get update -qqq >/dev/null
    for package in ${packages[@]};do
        echo -e "${ok}Installing $package"
        apt-get install -y -qqq $package &>/dev/null
    done
    if [ -f /usr/local/bin/docker-compose ];then
        echo -e "${ok}docker-compose already installed, It's recommended to be installed with latest version"
    else
        echo -e "${prog}Installing latest version of docker-compose"
        VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
        wget -nv -q -c --show-progress https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -O /usr/local/bin/docker-compose
        chmod 755 /usr/local/bin/docker-compose
    fi
}

containers_mem_tweak() {
    echo -e "${prog}Increasing max_map_count on the host"
    if [[ ! $(cat /etc/sysctl.conf | grep 'vm.max_map_count') ]];then
        echo "vm.max_map_count=262144" >> /etc/sysctl.conf
        sysctl -w vm.max_map_count=262144
        sysctl -p
    fi
}

generate_rev_proxy_certs() {
    env_vars=( "KIBANA_URL" "THEHIVE_URL" "CORTEX_URL" "MISP_URL" "SHUFFLE_URL" "KUMA_URL" )
    certs=( "kibana" "thehive" "cortex" "misp" "shuffle" "kuma" )
    
    echo -e "${prog}Generating reverse proxy domains self-signed certificates"
    if [ ! -d nginx/certs ]; then mkdir nginx/certs;fi

    for i in "${!env_vars[@]}";do
        if [ ! -f nginx/certs/${certs[i]}.crt ]; then
            echo -e "${prog}Generate certificate for ${certs[i]}"
            openssl req -x509 -sha256 -days 356 -nodes -newkey rsa:2048 -subj "/CN=${!env_vars[i]}/C=US/L=San Fransisco" -keyout nginx/certs/${certs[i]}.key -out nginx/certs/${certs[i]}.crt 2>/dev/null
        fi
    done
}

init_deployment() {
    docker_vols=( "elastic01_data" "elastic02_data" "kibana_data" "thehive_data" "shuffle/data" )
    for vol in ${docker_vols[@]};do
        if [ ! -d $vol ]; then mkdir -p $vol && chmod -R 777 $vol;fi
    done

    if [ -f docker-compose.yml ];then
        echo -e "${ok}Initiating deployment"
        docker-compose down;docker-compose up -d --build
    else
        echo -e "${err}docker-compose.yml file must be in the same current path!"
        exit 3
    fi
}

if [[ $(lsb_release -d | awk '{print $2}') -ne "Ubuntu" ]];then
    echo -e "${err}The deployment should be executed on ubuntu server."
    exit 1
elif [ $EUID -ne 0 ];then
    echo -e "${err}The deployment script should be run as root."
    exit 2
fi

install_pkgs
containers_mem_tweak
generate_rev_proxy_certs
init_deployment
