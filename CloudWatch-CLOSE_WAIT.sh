#!/bin/bash
# -----------------------------------------------------------------------------
# cloudwatch-close_wait.sh
# This script pushes the number of CLOSE_WAIT connections as a custom metric to 
# AWS CloudWatch.
#
# This script is designed to be run as a cron job for on-going stat collection.
#
# Created: 2018.07.05 by David Jones david.jones@greenpages.com
# -----------------------------------------------------------------------------
# Configuration Variable Definiitons
# -----------------------------------------------------------------------------
# Log File Configuration
LOG_FILE_PATH=/var/log/close_wait.log

# AWS Configuration
AWS_REGION=us-east-2

# Metric Configuration
CLOUDWATCH_METRIC_NAME=CloseWaitConnections
CLOUDWATCH_NAMESPACE=[NAMESPACE]

# Command Used to Pull the Metric
METRIC_VALUE=`netstat -pan | grep CLOSE_WAIT | wc -l`

# Simple Notification Service (SNS) Configuration
#SNS_TOPIC_ARN=
#SNS_TOPIC_SUBJECT="CloudWatch Custom Metric Failure"
#SNS_TOPIC_MESSAGE="The CloudWatch custom metric failed for server `hostname` at `date`."

# -----------------------------------------------------------------------------
# Script Body
# -----------------------------------------------------------------------------
# Push the vlaue to CloudWatch
/usr/bin/aws cloudwatch put-metric-data --region ${AWS_REGION} --metric-name ${CLOUDWATCH_METRIC_NAME} --namespace ${CLOUDWATCH_NAMESPACE} --value  ${METRIC_VALUE}
# Capture the return code form the CloudWatch AWS CLI command.
RETURN_CODE=$?
if [ $RETURN_CODE -eq 0 ]; then
        # Command completed successfully.
        # Log the successful completion of the S3 sync.
        # Log the value to a local log.
        echo "`date` `hostname` ${CLOUDWATCH_METRIC_NAME}: ${METRIC_VALUE}" | tee -a ${LOG_FILE_PATH}
else
        # Command failed.
        # Log the failure for troubleshooting purposes.
        echo "`date` `hostname` CloudWatch AWS CLI command failed with return value ${RETURN_CODE}" | tee -a ${LOG_FILE_PATH}
        # Publish the failure to an SNS topic for alerting.
        # /usr/bin/aws sns publish --region ${AWS_REGION} --topic-arn ${SNS_TOPIC_ARN} --subject "${SNS_TOPIC_SUBJECT}" --message "${SNS_TOPIC_MESSAGE}"
fi
