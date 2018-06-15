import requests
from requests.auth import HTTPBasicAuth
from base64 import b64encode

httpUrl = " "  #url
username = input("Enter your username: ")
password = input("Enter your pass: ")

response = requests.post(httpUrl, auth=HTTPBasicAuth('username', 'password'), verify=False)

print response.text





