import boto3
import sys
client = boto3.client('datapipeline')
##Assign Variables
plID=sys.argv[1]
UnqID="{0}_plID".format(plID)
#Create a pipeline
pipeline_create_response = client.create_pipeline(
    name="'{0}'".format(plID),
    uniqueId="'{0}'".format(UnqID),
    description="'This is data pipeline for {0}'".format(plID)
)
PipeLineId=pipeline_create_response['pipelineId']
print "The Pipeline ID for {0} is {1}.".format(plID, PipeLineId)

#put pipeline defination to existing pipeline
pipeline_defination_response = client.put_pipeline_definition(
    pipelineId="'{0}'".format(PipeLineId),
    pipelineObjects=[
    {
      "id": "ShellCommandActivityObj",
      "input": {
        "ref": "S3InputLocation"
      },
      "name": "ShellCommandActivityObj",
      "runsOn": {
        "ref": "EC2ResourceObj"
      },
      "command": "#{myShellCmd}",
      "output": {
        "ref": "S3OutputLocation"
      },
      "type": "ShellCommandActivity",
      "stage": "true"
    },
    {
      "id": "Default",
      "scheduleType": "CRON",
      "failureAndRerunMode": "CASCADE",
      "schedule": {
        "ref": "Schedule_15mins"
      },
      "name": "Default",
      "role": "DataPipelineDefaultRole",
      "resourceRole": "DataPipelineDefaultResourceRole"
    },
    {
      "id": "S3InputLocation",
      "name": "S3InputLocation",
      "directoryPath": "#{myS3InputLoc}",
      "type": "S3DataNode"
    },
    {
      "id": "S3OutputLocation",
      "name": "S3OutputLocation",
      "directoryPath": "#{myS3OutputLoc}/#{format(@scheduledStartTime, 'YYYY-MM-dd-HH-mm-ss')}",
      "type": "S3DataNode"
    },
    {
      "id": "Schedule_15mins",
      "occurrences": "4",
      "name": "Every 15 minutes",
      "startAt": "FIRST_ACTIVATION_DATE_TIME",
      "type": "Schedule",
      "period": "15 Minutes"
    },
    {
      "terminateAfter": "20 Minutes",
      "id": "EC2ResourceObj",
      "name": "EC2ResourceObj",
      "instanceType":"t1.micro",
      "type": "Ec2Resource"
    }
    ],
    parameterObjects=[
        {
      "id": "myShellCmd",
      "description": "Shell command to run",
      "type": "String",
      "default": "grep -rc \"GET\" ${INPUT1_STAGING_DIR}/* > ${OUTPUT1_STAGING_DIR}/output.txt"
    },
    {
      "id": "myS3InputLoc",
      "description": "S3 input location",
      "type": "AWS::S3::ObjectKey",
      "default": "s3://us-east-1.elasticmapreduce.samples/pig-apache-logs/data"
    },
    {
      "id": "myS3OutputLoc",
      "description": "S3 output location",
      "type": "AWS::S3::ObjectKey"
    }

    ],
    parameterValues=[
    {
      "myS3OutputLoc": "myOutputLocation"
    }
    ]
)

##Activate Pipeline
pipeline_activate_response = client.activate_pipeline(
    pipelineId="'{0}'".format(PipeLineId),
    parameterValues=[
        {
            'id': 'string',
            'stringValue': 'string'
        },
    ],
    startTimestamp=datetime(2015, 1, 1)
)

##Deactivate Pipeline
pipeline_deactivate_response = client.deactivate_pipeline(
    pipelineId="'{0}'".format(PipeLineId),
    cancelActive=False
)
ATMECSINLT-193:pipeline rgodishela$ 
