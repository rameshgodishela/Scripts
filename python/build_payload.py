#!/usr/bin/python
import os
import socket
import json
import logging,subprocess

logging.basicConfig(filename='/var/log/auto_register.log',level=logging.DEBUG)

with open(os.getcwd() + "/config.json", "r") as config:
    data = json.loads(config.read())

# types for building payload data
final_payload = dict()
service = {}
tags = []
container_ip = None
sys_host_name = None
sys_ip = None
#  get hostname of the host machine
sys_fqdn = socket.gethostname()
# Get host ip
sys_ip = socket.gethostbyname(sys_fqdn)
inspect_required_keys = ["Env", "Labels", "Hostname", "NetworkID", "IPAddress", "Volumes", "Image", "ExposedPorts", "Networks"]


def build_label(value):
    for lkey, lvalue in value.iteritems():
        tags.append("label:" + str(lkey) + "=" + str(lvalue))


def build_env(value):
    for evalue in value:
        tags.append("env:" + str(evalue))


def build_network(value):
    #fetching network name
    if isinstance(value,dict):
        tags.append("net:" + str(value.keys()[0]))
    else:
        tags.append("net:null")

def calculate_payload(inspect_data, required_keys):
    """ Creates Service Payload  """
    try:
        for ikey in inspect_data.keys():
            if isinstance(inspect_data[ikey], dict):
                for key, value in inspect_data[ikey].iteritems():
                    if key in required_keys:
                        if key == "Labels":
                            build_label(value)

                        elif key == "Env":
                            build_env(value)

                        elif key == "Networks":
                            build_network(value)
                    else:
                        tags.append(str(key) + ":" + str(value))
            else:
                pass
                #final_payload[ikey] = inspect_data[ikey]
    except Exception as e:
            logging.error("key in required_keys does not exist in the inspect data")

def build_payload(cli, event):

    container_name = event["Actor"]["Attributes"]["name"]
    #logging.info("service container name is ", container_name)
    inspect_data = cli.inspect_container(container_name)
    logging.info(inspect_data.keys())

    calculate_payload(inspect_data, inspect_required_keys)
    #fetching short hostname
    short_host_name = subprocess.Popen(['hostname', '-s'], stdout=subprocess.PIPE)
    final_payload["Node"] = short_host_name.communicate()[0]
    final_payload["Datacenter"] = str(data["datacenter"])
    service["Address"] = inspect_data["NetworkSettings"]["IPAddress"]
    logging.info("service address is"+service["Address"])

    if len(inspect_data["NetworkSettings"]["Ports"]) == 0:
        service["Port"] = None
    else:
        service["Port"] = int(inspect_data["NetworkSettings"]["Ports"].keys()[0].split("/")[0])
    
    container_name_list = inspect_data['Name'].split('_')
    service["Service"] = str(container_name_list[2])
    service["Tags"] = tags
    final_payload["Service"] = service
    final_payload["Address"] = sys_ip
    final_payload["Namespace"] = str(container_name_list[3])
    final_payload["TaggedAddresses"] = None

    logging.info("this is final payload: "+"\n\n"+json.dumps(final_payload)+"\n\n")

    #logging.debug(final_payload)

    return final_payload