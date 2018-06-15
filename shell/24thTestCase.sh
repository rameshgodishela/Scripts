#!/usr/bin/env bash

node1="10.10.48.166"
node2="10.10.48.167"
node3="10.10.48.168"


ssh_machine() {
    host=$1
    shift;
    command=$@
    private_key_value=$(ls -1 /home/core/.ssh/c23515_malt-pilot.pri)
    if [ "$private_key_value" == "/home/core/.ssh/c23515_malt-pilot.pri" ]
    then
        ssh -i $private_key_value -o "StrictHostKeyChecking no" -l core $host $command
    else
        echo "Private key file is not found in /home/core/.ssh/, unable to ssh $host"
        exit 1
    fi
}

setup_test() {
node1=$1
node2=$2
node3=$3

for node_val in $node1 $node2 $node3 
do
  for svc_val in portworx fleet 
  do 
    node_svc_status=$(ssh_machine $node_val sudo systemctl is-active $svc_val)
    if [ "$node_svc_status" != "active" ]
    then
       echo "$svc_val is $node_svc_status in $node_val ..starting $svc_val now"
       ssh_machine $node_val sudo systemctl start $service_val
    else
       echo "$svc_val is in $node_val inactive"
    fi
  done
done
}

run_test() {
node1=$1
node2=$2
node3=$3
echo "List all units in the fleet cluster..before tests run"
fleetctl list-units
echo "Stopping the portworx in $node3..."
ssh_machine $node3 sudo systemctl stop portworx
node3_pwx_=$(ssh_machine $node3 sudo systemctl is-active portworx)
if [ "$node3_pwx" != "active" ]
then
    echo "PASS: portworx is $node3_pwx in $node3"
    time = 1
    while [[ $time -le 12 ]] 
    do 
      echo "portworx volume list from $node1"
      ssh_machine $node1 sudo /opt/pwx/bin/pxctl v l 
      echo "portworx volume list from $node3"
      ssh_machine $node1 sudo /opt/pwx/bin/pxctl v l 
      echo "portworx volume list from $node1"
      ssh_machine $node2 /opt/pwx/bin/pxctl status
      echo "portworx volume list from $node3"
      ssh_machine $node2 /opt/pwx/bin/pxctl status
      (( time++ ))
      sleep 60
    done
fi
echo "List all units in the fleet cluster..after tests run"
fleetctl list-units

}
status_check() {
   Interested_Services=("etcd-member" "docker" "portworx" "flanneld" "fleet")
   for Service in "${Interested_Services[@]}"
   do 
     Service_Status=$(sudo systemctl is-active $Service)
     echo "$Service is $Service_Status"
   done
   pxctl_status=$(/opt/pwx/bin/pxctl status| awk -F":" '/Status/ {print $2}')
   echo "$pxctl_status"
   echo "List all machines in the fleet cluster.."
   fleetctl list-machines
   echo "List all units in the fleet cluster.."
   fleetctl list-units
   etcd_health=$(etcdctl cluster-health| awk 'NR>1 {print $0}')
   echo "etcd $etcd_health"
}

echo "Checking the important services status..before running tests"
status_check 
echo "Preparing the environment before testing.."
setup_test $node1 $node2 $node3
echo "Tests are running at:" $(date) 
run_test $node1 $node2 $node3
echo "Please note the results, gonna cleanup the environment.."
echo "Checking the important services status..after running tests"
status_check
