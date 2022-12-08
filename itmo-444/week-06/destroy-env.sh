#!/bin/bash

########################
# Destroy the Instances
########################

IDS=$(aws ec2 describe-instances --output=table --no-cli-pager | grep InstanceId | awk {'print $4'})

echo $IDS

aws ec2 terminate-instances --instance-ids $IDS --no-cli-pager

###################
# Destroy Listener
###################

LB=$(aws elbv2 describe-load-balancers --output=text --query='LoadBalancers[*].LoadBalancerArn' --no-cli-pager)
LISTEN=$(aws elbv2 describe-listeners --load-balancer-arn $LB --output=text --query='Listeners[*].ListenerArn' --no-cli-pager)

aws elbv2 delete-listener \
    --listener-arn $LISTEN \
    --no-cli-pager

echo "Listener Deleted"

##########################
# Destroy the target group
##########################

TG=$(aws elbv2 describe-target-groups --output=text --query='TargetGroups[*].TargetGroupArn' --no-cli-pager)

aws elbv2 delete-target-group \
    --target-group-arn $TG \
    --no-cli-pager

echo "Target Group deleted"

#######################
# Destroy Load Balancer
#######################

aws elbv2 delete-load-balancer \
    --load-balancer-arn $LB \
    --no-cli-pager

aws elbv2 wait load-balancers-deleted \
        --load-balancer-arns $LB \
        --no-cli-pager

echo "Load Balancer Destroyed"