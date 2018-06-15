#!/usr/bin/bash
#set -x
# to run the script: bash <scriptname>
# output will be saved in /tmp/df.txt

#ssh_machine function helps you to run the command remotely
ssh_machine() {
host=$1
shift;
command=$@
ssh -q -o "StrictHostKeyChecking no" -l root $host $command
}

#df_format function formats the output
df_format() {
ALERT=40
while read output;
do
    usage_percentage=$(echo $output | awk '{ print $5}' | cut -d'%' -f1)
    mounted_on=$(echo $output | awk '{print $6}')
    if [ $usage_percentage -ge $ALERT ] ; then
      awk 'BEGIN { format = "%-70s %-4s  %-4s  %-4s  %-4s  %-4s\n" 
      printf format, "Filesystem", "Size", "Used", "Avail", "Use%", "Mounted on"
      printf format, "----------", "----", "----", "-----", "----", "----------" }' 
      echo $output | awk 'BEGIN { format = "%-70s %-4s  %-4s  %-4s  %-4s  %-4s\n"} { printf format, $1, $2, $3, $4, $5, $6 }' 
    fi
done
}

#disk_space_check function get the diskspace in listed servers in servers.txt file
disk_space_check() {
for server in $(<servers.txt)
do
  echo "Disk space utilization Report: Filesystem Use% more than $ALERT% on server $server, $(date)" 
  ssh_machine $server df -PH | grep -vE "^Filesystem" | awk '{print $1 " " $2 " " $3 " " $4 " " $5 " " $6}' | df_format
done
}

#Send an email and alert the team once the report is ready
disk_space_check > /tmp/df.txt
EMAIL_DL="iamrameshjonathan@gmail.com"
mail -s "Alert: Disk space Utilization Report" $EMAIL_DL < /tmp/df.txt

exit 0
