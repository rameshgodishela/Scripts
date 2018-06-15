#!/usr/bin/env bash
# Testing whether portworx dies or not when Flannel daemon dies

setup_test(){
    
    fleet_status=$(sudo systemctl is-active fleet)
    if [ "$fleet_status" != "active" ]
    then
        echo "fleet is $fleet_status"
        echo "starting fleet.."
        sudo systemctl start fleet
    else
        echo "fleet is $fleet_status"
    fi

    pwx_status=$(sudo systemctl is-active portworx)
    if [ "$pwx_status" != "active" ]
    then
        echo "Portworx is $pwx_status"
        echo "starting Portworx.."
        sudo systemctl start portworx
    else
        echo "Portworx is $pwx_status"
    fi
}

run_test() {
    echo "Stopping the fleet.."
    sudo systemctl stop fleet  
    sleep 5

    fleet_status=$(sudo systemctl is-active fleet)
    if [ "$fleet_status" != "active" ]
    then
        echo "PASS: fleet stopped"
    else
        echo "FAIL: Unable to stop the fleet daemon"
    fi

    pwx_status=$(sudo systemctl is-active portworx)
    if [ "$pwx_status" != "active" ]
    then
        echo "FAIL: Portworx impacted when fleet is dead."
    else
        echo "FAIL: Portworx is still active because It is not impacted when fleet dies.."
    fi
    echo "Checking the application using portworx behaviour"

    pwx_app_status=$(docker ps --filter status=running --format "table {{.Status}}" | awk 'NR>1 {print $1}')
    
        if [ "$pwx_app_status" != "Up" ]
    then
        echo "FAIL: An app using Portworx impacted when fleet is dead."
    else
        echo "PASS: An app using Portworx not impacted when fleet is dead."
    fi
    echo "List all units in the fleet cluster.."
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

cleanup() {
      sudo systemctl start fleet
      sudo systemctl start portworx
}
echo "Checking the important services status..before running tests"
status_check
echo "Preparing the environment before testing.."
setup_test
echo "Tests are running at:" $(date) 
run_test
echo "Please note the results, gonna cleanup the environment.."
cleanup
echo "Checking the important services status..after running tests"
status_check
