import requests

url = "http://d_con_pso_discovery.db.gld.dreamworks.net:8500/v1/catalog/nodes"

querystring = {"cluster-meta":"in_user:true","token":"5adc23b4-8111-c478-9682-336bf1f65593"}

payload = "{\n  \"id\":\"31333138-3839-4D32-3236-333430353871\",\n  \"Node\": \"pb-pso-071.gld.dreamworks.net\",\n  \"Address\": \"10.40.2.71\",\n  \"NodeMeta\": {\n    \"in_use\": \"true\",\n    \"env\": \"test\"\n  }\n}"
headers = {
    'content-type': "application/json",
    'x-consul-token': "bb99e28f-45a5-693b-65e6-d33cc47961e3",
    'cache-control': "no-cache",
    'postman-token': "b4a76472-3316-9c90-73b6-c2c59c623288"
    }

response = requests.request("GET", url, data=payload, headers=headers, params=querystring)

print(response.text)


