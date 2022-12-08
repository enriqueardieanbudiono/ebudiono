#!/bin/bash
set -e

######################################################################
# Format of arguments.txt
# $1 image-id
# $2 instance-type
# $3 key-name
# $4 security-group-ids
# $5 count (3)
# $6 availability-zone
# $7 elb name
# $8 target group name
# $9 auto-scaling group name
# ${10} launch configuration name
# ${11} db instance identifier (database name)
# ${12} db instance identifier (for read-replica), append *-rpl*
# ${13} min-size = 2
# ${14} max-size = 5
# ${15} desired-capacity = 3
# ${16} Database engine (use mariadb)
# ${17} Database name ( use company )
# ${18} s3 raw bucket name (use initials and -raw)
# ${19} s3 finished bucket name (use initials and -fin)
# {20} aws secret name
# {21} iam-instance-profile
######################################################################

#######################
# Destroy the S3 bucket
#######################
LISTOFBUCKETS=$(aws s3api list-buckets --query 'Buckets[*].Name')

# Use for loop to delete multiple buckets
for i in $LISTOFBUCKETS
do
    KEY=$(aws s3api list-objects --bucket ebudi-raw --output=text --query="Contents[*].Key")

    echo "Deleting object inside bucket $i"
    aws s3api delete-object \
    --bucket $i \
    --key $KEY

    echo "Deleting bucket $i"
    aws s3api delete-bucket \
        --bucket $i
done

echo "Buckets deletion complete"

######################
# Destroy db instance
######################
DBRPL=$(aws rds describe-db-instances --output=text --query='DBInstances[1].DBInstanceIdentifier')

echo "Deleting db instance $DBRPL"
aws rds delete-db-instance \
    --db-instance-identifier $DBRPL \
    --skip-final-snapshot \
    --no-cli-pager

echo "Waiting for $DBRPL to be deleted"

aws rds wait db-instance-deleted \
    --db-instance-identifier $DBRPL \
    --no-cli-pager

echo "Database $DBRPL deleted"

DB=$(aws rds describe-db-instances --output=text --query='DBInstances[0].DBInstanceIdentifier')

echo "Deleting db instance $DB"
aws rds delete-db-instance \
    --db-instance-identifier $DB \
    --skip-final-snapshot \
    --no-cli-pager

echo "Waiting for $DB to be deleted"

aws rds wait db-instance-deleted \
    --db-instance-identifier $DB \
    --no-cli-pager

echo "Database $DB deleted"

########################
# Destroy the Instances
########################

echo "Terminating instances..."

IDS=$(aws ec2 describe-instances --output=table --no-cli-pager | grep InstanceId | awk {'print $4'})

echo $IDS

aws ec2 terminate-instances --instance-ids $IDS --no-cli-pager

echo "Waiting for instances to terminate..."

aws ec2 wait instance-terminated \
    --instance-ids $IDS \
    --no-cli-pager

echo "Instances terminated"

#############################
# Destroy auto-scaling group
#############################

AG=$(aws autoscaling describe-auto-scaling-groups --output=text --query='AutoScalingGroups[*].AutoScalingGroupName')

echo "Deleting auto-scaling group $AG"

aws autoscaling delete-auto-scaling-group \
    --auto-scaling-group-name $AG \
    --force-delete \
    --no-cli-pager

echo "Auto-scaling group $AG deleted"

###############################
# Destroy launch configuration
###############################

LC=$(aws autoscaling describe-launch-configurations --output=text --query='LaunchConfigurations[*].LaunchConfigurationName')

echo "Deleting launch configuration $LC"

aws autoscaling delete-launch-configuration \
    --launch-configuration-name $LC \
    --no-cli-pager

echo "Launch configuration $LC deleted"

###################
# Destroy Listener
###################

LB=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn' --no-cli-pager)
LISTEN=$(aws elbv2 describe-listeners --load-balancer-arn $LB --output=text --query='Listeners[*].ListenerArn' --no-cli-pager)

echo "Deleting listener"
aws elbv2 delete-listener \
    --listener-arn $LISTEN \
    --no-cli-pager

echo "Listener Deleted"

##########################
# Destroy the target group
##########################

TG=$(aws elbv2 describe-target-groups --output=text --query='TargetGroups[*].TargetGroupArn' --no-cli-pager)

echo "Deleting target group"
aws elbv2 delete-target-group \
    --target-group-arn $TG \
    --no-cli-pager

echo "Target Group deleted"

#######################
# Destroy Load Balancer
#######################

echo "Deleting load balancer"
aws elbv2 delete-load-balancer \
    --load-balancer-arn $LB \
    --no-cli-pager

aws elbv2 wait load-balancers-deleted \
        --load-balancer-arns $LB \
        --no-cli-pager

echo "Load Balancer Destroyed"

#######################
# Destroy the secret
#######################
SECRETID=$(aws secretsmanager list-secrets --output=text --query="SecretList[*].Name" --no-cli-pager)

echo "Deleting secret $SECRETID"
aws secretsmanager delete-secret \
    --secret-id $SECRETID \
    --force-delete-without-recovery \
    --no-cli-pager

echo "$SECRETID deleted"