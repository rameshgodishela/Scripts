import requests
import json
class paas_cluster_manager_healthcheck:
   def healthcheck()
       response = requests.get('http://paas-cluster-manager.service.local:3000/')
       if response.status_code == 200:
          clustr_mgr_response = response.json()
          clustr_mgr_responsee = json.loads(clustr_mgr_response)
          print json.dumps(clustr_mgr_responsee, indent=4, sort_keys=True)
       else:
          print "WARN: paas-cluster-manager.service is down on port 3000"
          print response.raise_for_status()


