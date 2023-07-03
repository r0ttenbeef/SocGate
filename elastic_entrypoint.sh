#!/bin/bash

echo "[+]Initiate certificates generating for elasticsearch.."

if [ $EUID -ne 0 ];then
    echo "[-]User must be root inside the elasticsearch container"
    exit 2
fi

if [ x${ELASTIC_PASSWORD} == x ]; then
    echo "[-]Set the ELASTIC_PASSWORD environment variable in the .env file"
    exit 1
        
elif [ x${KIBANA_PASSWORD} == x ]; then
    echo "[-]Set the KIBANA_PASSWORD environment variable in the .env file"
    exit 1
fi

if [ ! -d config/certs ];then mkdir config/certs;fi

if [ ! -f config/certs/ca.zip ]; then
    echo "[*]Creating CA"
    bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip
    unzip config/certs/ca.zip -d config/certs
fi

if [ ! -f config/certs/certs.zip ]; then
    echo "[*]Creating certs"
    bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key
    unzip config/certs/certs.zip -d config/certs
fi
        
echo "[+]Setting file permissions"
chown -R root:root config/certs
        
echo "[*]Waiting for Elasticsearch availability"
until curl -s --cacert config/certs/ca/ca.crt https://elastic01:9200 | grep -q "missing authentication credentials"; do sleep 30; done
        
echo "[*]Setting kibana_system password"
until curl -s -X POST --cacert config/certs/ca/ca.crt -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" https://elastic01:9200/_security/user/kibana_system/_password -d "{\"password\":\"${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do sleep 10; done

echo "[+]Task is done!"
