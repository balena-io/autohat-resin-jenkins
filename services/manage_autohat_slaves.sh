#!/bin/bash

FTDI_strings=(`lsusb -d 0403:6001 -v  | grep 'iManufacturer\|iProduct\|iSerial' | awk '{print $3}'`)
FTDI_strings_count=${#FTDI_strings[@]}
ATTACHED_Rigs=()
for (( c=0; c<${FTDI_strings_count}; c=c+3 ))
do
	if [ "${FTDI_strings[c]}" == "Resin.io" ]
	then
		device_type=$(echo ${FTDI_strings[c+1]} | cut -d ":" -f2 )
		rig_device_id=${FTDI_strings[c+2]}
		ATTACHED_Rigs+=(${device_type}_${rig_device_id})
		if ! systemctl -q is-active autohat_jenkins_slave@${device_type}_${rig_device_id}
		then
			echo "Activating: ${device_type}_${rig_device_id}"
			systemctl start autohat_jenkins_slave@${device_type}_${rig_device_id}
		fi

	fi
done
ACTIVE_Rigs=(`systemctl list-units autohat_jenkins_slave@*.service | grep running | awk '{print $1}' | cut -d '@' -f 2 | cut -d '.' -f 1`)
MISSING_Rigs=(`comm -13 <(printf '%s\n' "${ATTACHED_Rigs[@]}" | LC_ALL=C sort) <(printf '%s\n' "${ACTIVE_Rigs[@]}" | LC_ALL=C sort)`)
for i in "${!MISSING_Rigs[@]}"; do
	echo "Deactivating: ${MISSING_Rigs[$i]}"
	systemctl stop autohat_jenkins_slave@${MISSING_Rigs[$i]}
done
