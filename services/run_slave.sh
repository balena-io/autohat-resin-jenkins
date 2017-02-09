#!/bin/bash

rig_string=$1
export device_type=$(echo $rig_string | cut -d "_" -f 2)
export sku=$(echo $rig_string | cut -d "_" -f 3)
export rig_device_id=$(echo $rig_string | cut -d "_" -f 1)
export rig_sd_card=/dev/disk_$rig_device_id
export application_name=rig_$rig_device_id
/usr/bin/java -jar /swarm-client.jar -disableClientsUniqueId -fsroot /data/$rig_device_id -name $application_name -labels $LOCATION -labels Serial:$rig_device_id -labels $device_type -labels $sku -master $JENKINS_MASTER -username $JENKINS_USERNAME -passwordEnvVariable JENKINS_PASSWORD -executors 1 -retry 10 -mode exclusive
