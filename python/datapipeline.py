#!/usr/bin/env python
import boto3
import sys
import json
import subprocess
import datetime
import time
from subprocess import PIPE,Popen
client = boto3.client('datapipeline')
## Make sure tha you have accesskey and secret key in ~/.aws/credentials path
##Assign Variables
plID=sys.argv[1]
UnqID="{0}_plID".format(plID)
#timetostart=sys.argv[2]
#Create a pipeline
pipeline_create_response = client.create_pipeline(
    name="'{0}'".format(plID),
    uniqueId="'{0}'".format(UnqID),
    description="'This is data pipeline for {0}'".format(plID)
)
PipeLineId=pipeline_create_response['pipelineId']
print "The Pipeline ID for {0} is {1}.".format(plID, PipeLineId)

#Put pipeline defination
command="aws datapipeline put-pipeline-definition --pipeline-id {0} --pipeline-definition file://pipeline-definition.json".format(PipeLineId)
process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
process.wait()
if process.returncode == 0:
   print "Your pipeline defination uploaded and validated successfully..you may activate the pipeline({0})".format(PipeLineId)
   print "waiting for the pipeline to be available to activate...please standby"
#   time.sleep(90)
else:
   print "Your pipeline definition seems to be not acceptable..Read below output for the errors."
   print process.check_output()
   sys.exit()

#Activate pipeline
## Uncomment when you wanted to use start timestap 39th line, 14thline and comment 40the line
#activate_command="aws datapipeline activate-pipeline --pipeline-id {0} --start-timestamp {1}".format(PipeLineId, timetostart)
activate_command="aws datapipeline activate-pipeline --pipeline-id {0} ".format(PipeLineId)
activate_process = subprocess.Popen(activate_command, shell=True, stdout=subprocess.PIPE)
activate_process.wait()
if activate_process.returncode == 0:
   print "The Pipeline is activated for {0} is {1}.".format(plID, PipeLineId)
else:
   print "Your pipeline is not activated..Read below output for the errors."
   print activate_process.check_output()

##Deactivate Pipeline
#pipeline_deactivate_response = client.deactivate_pipeline(
#    pipelineId="'{0}'".format(PipeLineId),
#    cancelActive=False
#)
#print "The Pipeline is de-activated for {0} is {1}.".format(plID, PipeLineId)
#print pipeline_deactivate_response