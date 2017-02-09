#!/bin/bash

rig_string=$1
export device_type=$(echo $rig_string | cut -d "_" -f 1)
export rig_device_id=$(echo $rig_string | cut -d "_" -f 2)
export rig_sd_card=/dev/disk_$rig_device_id
export application_name=rig_$rig_device_id
/usr/bin/java -jar /etc/autohat/swarm-client.jar -disableClientsUniqueId -name $application_name -labels $LOCATION -labels Serial:$rig_device_id -labels $device_type -master $JENKINS_MASTER -username $JENKINS_USERNAME -passwordEnvVariable JENKINS_PASSWORD -executors 1 -retry 10 -mode exclusive
