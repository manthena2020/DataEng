
#!/bin/env python

import requests
import json
import hashlib
import base64
import time
import hmac
import getpass

#Account Info: LogicMonitor recommends to NEVER hardcode the credentials. Instead, retrieve the values from a secure storage.
#Note: The below is provided for illustration purposes only.
AccessId = getpass.getpass(" ")
AccessKey = getpass.getpass(" ")
Company = 'spinnaker' 

##Request Info
httpVerb ='GET'
resourcePath = '/device/devices/659/devicedatasources/61834/instances/63510792'

queryParams = ''
data = '/data?period=10&start=1696809600&end=1699488000&datapoints=Running&format=json'


#Construct URL 
url = 'https://spinnakersupport.logicmonitor.com/santaba/rest'


#Get current time in milliseconds
epoch = str(int(time.time() * 1000))


#Concatenate Request details
requestVars = httpVerb + epoch + data + resourcePath

#Construct signature
digest = hmac.new(
        AccessKey.encode('utf-8'),
        msg=requestVars.encode('utf-8'),
        digestmod=hashlib.sha256).hexdigest()
signature = base64.b64encode(digest.encode('utf-8')).decode('utf-8')

# Construct headers
auth = 'LMv1 ' + AccessId + ':' + str(signature) + ':' + epoch 
headers = {'Content-Type':'application/json','Authorization':auth}

#Make request
response = requests.get(url, data=data, headers=headers)

#Print status and body of response
print ('Response Status:',response.status_code)
print ('Response Body:',response.content)
