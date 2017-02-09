#!/bin/bash

FTDI_strings=(`lsusb -d 0403:6001 -v  | grep 'iManufacturer\|iProduct\|iSerial' | awk '{print $3}'`)
FTDI_strings_count=${#FTDI_strings[@]}
ATTACHED_Rigs=()
for (( c=0; c<${FTDI_strings_count}; c=c+3 ))
do
	if [ "${FTDI_strings[c]}" == "Resin.io" ]
	then
		device_type=$(echo ${FTDI_strings[c+1]} | cut -d ":" -f2 | cut -d "[" -f1 )
		sku=$(echo ${FTDI_strings[c+1]} |  cut -d ":" -f2 | cut -d "[" -f2 | cut -d "]" -f1)
		rig_device_id=${FTDI_strings[c+2]}
		ATTACHED_Rigs+=(${rig_device_id}_${device_type}_${sku})
		if ! systemctl -q is-active autohat_jenkins_slave@${rig_device_id}_${device_type}_${sku}
		then
			echo "Activating: ${rig_device_id}_${device_type}_${sku}"
			systemctl start autohat_jenkins_slave@${rig_device_id}_${device_type}_${sku}
		fi

	fi
done
ACTIVE_Rigs=(`systemctl list-units autohat_jenkins_slave@*.service | grep running | awk '{print $1}' | cut -d '@' -f 2 | cut -d '.' -f 1`)
MISSING_Rigs=(`comm -13 <(printf '%s\n' "${ATTACHED_Rigs[@]}" | LC_ALL=C sort) <(printf '%s\n' "${ACTIVE_Rigs[@]}" | LC_ALL=C sort)`)
for i in "${!MISSING_Rigs[@]}"; do
	echo "Deactivating: ${MISSING_Rigs[$i]}"
	systemctl stop autohat_jenkins_slave@${MISSING_Rigs[$i]}
done
