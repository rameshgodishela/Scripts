#!/usr/bin/env python 
import consulate
import requests
import json 
import sys
import re
## Program variables
cluster_type = sys.argv[1]
masters = sys.argv[2]
nodes = sys.argv[3]
consul_server = sys.argv[4]
consul_token = sys.argv[5]

master_servers = masters.split(',') #master servers list
etcd_servers = masters.split(',') #etcd servers list
node_servers = nodes.split(',') #node servers list
total_list = master_servers + node_servers
if (len(master_servers)) < 1 or (len(node_servers) < 1):
   print "WARN: Please drop your interest to build a {0} with 1 server.".format(cluster_type)
   sys.exit(1)
   
print '\n'
print "INFO: The below servers are going to be masters,etcd in {0} Cluster".format(cluster_type)
for srv in master_servers:
    print srv
print '\n'
print "INFO: The below servers are going to be nodes in {0} Cluster".format(cluster_type)
for srv in node_servers:
    print srv
print '\n'

#Retriving the Clsuter related info from dev consul cluster
session = consulate.Consul(host=consul_server,port=8500,scheme='http',token=consul_token)
public_hostname = session.kv.get('tesseract/cluster/'+ cluster_type + '/publichostname')
private_hostname = session.kv.get('tesseract/cluster/'+ cluster_type + '/privatehostname')
pingid = session.kv.get('tesseract/cluster/'+ cluster_type + '/pingidname')
pingid_token = session.kv.get('tesseract/cluster/'+ cluster_type + '/pingidtoken')
short_name = session.kv.get('tesseract/cluster/'+ cluster_type + '/shortname')
publicname_parts = public_hostname.split('/')
publicname = publicname_parts[2].split(':')[0]
auth_url = 'https://sso.dreamworks.com:9031/as/authorization.oauth2'
auth_token = 'https://sso.dreamworks.com:9031/as/token.oauth2'
##Assigning certificates related info
##We consutructed the certs dictionary assuming that the generated certs will be stored in /root directory of relevant node
openshift_master_named_certificates = '[{{"certfile": "/root/%s.crt", "keyfile": "/root/%s.key", "names": ["%s"], "cafile": "/root/ca.crt"}}]' % (publicname)
## Assigning PINGId info
openshift_master_identity_providers = '[{"name": "%s", "challenge": "false", "login": "true", "kind": "OpenIDIdentityProvider", "clientID": "%s", "clientSecret": "{1}", "claims": {"id":["sub"], "preferredUsername": ["preferred_username","email"], "name": ["nickname","given_name","name"], "email": ["email"]}, "urls": {"authorize":"%s","token":"%s"} } ]' % (pingid, pingid_token, auth_url, auth_token)
## Consutructing Labels
node_labels = "'region': 'gld', 'cluster': '{0}', 'logging-infra-fluentd': 'true'".format(cluster_type)
master_labels = "'cluster': '{0}', 'logging-infra-fluentd': 'true', 'zone': 'master', 'logging-es-node': '1', 'logging-infra': 'true'".format(cluster_type)
sched_status= 'openshift_schedulable=true'
write_file = '{0}/hosts'.format(cluster_type)

## we are reading from a hosts template and writing to relevant cluster/hosts file
with open('templates/hosts.template', 'r') as Hosts_Template_To_Read:
    with open(write_file, 'w+') as Hosts_File_To_Write:
        for line in Hosts_Template_To_Read:
            if line == 'openshift_master_cluster_hostname\n':
                line = 'openshift_master_cluster_hostname={}\n'.format(private_hostname)
                Hosts_File_To_Write.write(line)
            elif line == 'openshift_master_cluster_public_hostname\n':
                 line = 'openshift_master_cluster_public_hostname={}\n'.format(publicname)
                 Hosts_File_To_Write.write(line)
            elif line == 'openshift_master_named_certificates\n':
                 line = 'openshift_master_named_certificates={}\n'.format(openshift_master_named_certificates)
                 Hosts_File_To_Write.write(line)
            elif line == 'openshift_master_identity_providers\n':
                 line = 'openshift_master_identity_providers={}\n'.format(openshift_master_identity_providers)
                 Hosts_File_To_Write.write(line)
            elif line == 'ose_masters\n':
                 for m_srv in master_servers:
                     line = '{0}\n'.format(m_srv)
                     Hosts_File_To_Write.write(line)
            elif line == 'ose_etcd\n':
                 for e_srv in etcd_servers:
                     line = '{0}\n'.format(e_srv)
                     Hosts_File_To_Write.write(line)
            elif line == 'ose_nodes\n':
                 for node_server in total_list:
                     try:
                        router_id = session.catalog.node(node_server)['Node']['Meta']['openshift_node_ospf_router_id']
                        pod_net = session.catalog.node(node_server)['Node']['Meta']['openshift_node_pod_net']
                     except KeyError:
                        print 'WARN: Quagga details are not available for {0}'.format(node_server)
                        print '\nWARN: Quagga details are needed to set the variables openshift_node_ospf_router_id and openshift_node_pod_net.\n'
                        sys.exit(1)
                     if node_server in master_servers:
                         line = '{0} openshift_node_labels="{{{1}}}" openshift_node_ospf_router_id={2} openshift_node_pod_net={3} {4} \n'.format(node_server, master_labels, router_id, pod_net, sched_status)
                     else:
                         line = '{0} openshift_node_labels="{{{1}}}" openshift_node_ospf_router_id={2} openshift_node_pod_net={3} \n'.format(node_server, node_labels, router_id, pod_net)
                     Hosts_File_To_Write.write(line)
            else: 
                Hosts_File_To_Write.write(line)

print "INFO: Hosts file saved in Github repo http://github.anim.dreamworks.com/PSO/ose_setup.git"