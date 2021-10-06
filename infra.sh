#!/bin/bash
set -x
PROXY=""
NO_PROXY=""
PROV_KEY=""
GATEWAY_IP=""


function userManual() {
	echo "--proxy               Value:Proxy settings of the PoP".
	echo "--no_proxy                Value:No Proxy list for the PoP".
	echo "--provision_key                  Value:Provision key for Private Access".
	echo "--gateway               Value:Gateway Hostname/IP address for Private Access".
}

for i in "$@";
do
    key=$(echo $i | cut -f1 -d=)
	if [ $key = "--provision_key" ]; then
	  value=$(echo $i | cut -d '=' -f 2-)
	else
		value=$(echo $i | cut -f2 -d=)
	fi

	if [ "$key" = "--proxy" ]; then
		PROXY=$value
	elif [ "$key" = "--no_proxy" ]; then
		NO_PROXY=$value
	elif [ "$key" = "--gateway" ]; then
		GATEWAY_IP=$value
	elif [ "$key" = "--provision_key" ]; then
		PROV_KEY=$value
	else
		echo "PROXY, NO_PROXY, GATEWAY_IP and PROV_KEY are not configured"
	fi
done

mkdir -p /opt/McAfee/cwpp/pop

if [ "$1" = "-help" ] || [ "$1" = "-h" ]; then
    echo "Usage: `basename $0` $PROV_KEY $GATEWAY_IP $PROXY $NO_PROXY"
    echo "Provide PROV_KEY and GATEWAY_IP for Private Access deployment."
fi

cp PoPDeployment.tar /opt/McAfee/cwpp/pop/
cd /opt/McAfee/cwpp/pop
sudo tar -xvf /opt/McAfee/cwpp/pop/PoPDeployment.tar --one-top-level -C /opt/McAfee/cwpp/pop >> /opt/McAfee/cwpp/pop/install.log 
sudo tar -xvf /opt/McAfee/cwpp/pop/PoPDeployment/PoPCreation.tar --one-top-level -C /opt/McAfee/cwpp/pop/PoPDeployment  >> /opt/McAfee/cwpp/pop/install.log 
sudo tar -xvf /opt/McAfee/cwpp/pop/PoPDeployment/PoPServicesConfig.tar --one-top-level -C /opt/McAfee/cwpp/pop/PoPDeployment >> /opt/McAfee/cwpp/pop/install.log
sudo bash /opt/McAfee/cwpp/pop/PoPDeployment/PoPCreation/vCenter/setup_microk8s_vCenter.sh --setupprimary --provision_key=$PROV_KEY --gateway=$GATEWAY_IP --proxy=$PROXY --no_proxy=$NO_PROXY >> /opt/McAfee/cwpp/pop/install.log
