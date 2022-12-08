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
######################################################################

#########
# GETTER
#########
VPCID=$(aws ec2 describe-vpcs --output=text --query='Vpcs[*].VpcId')
SUBNET1=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=us-east-2a")
SUBNET2=$(aws ec2 describe-subnets --output=text --query='Subnets[*].SubnetId' --filter "Name=availability-zone,Values=us-east-2c")

####################################################################################################
# Launch 3 EC2 instances
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/wait/instance-running.html
####################################################################################################
echo "Launching 3 EC2 instances of count $5"

aws ec2 run-instances --image-id $1 --instance-type $2 --key-name $3 --security-group-ids $4 --count $5 --user-data file://install-env.sh --no-cli-pager

# Checking the instances id
EC2IDS=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running,pending --query='Reservations[*].Instances[*].InstanceId')

echo "EC2 IDS content: $EC2IDS"

###################################
# Wait EC2 instances to be running
###################################
echo "Waiting for EC2 instances to be running..."

aws ec2 wait instance-running --instance-ids $EC2IDS --no-cli-pager

######################
# Create Target Group
######################
echo "Creating Target Group $8 ...."

TGARN=$(aws elbv2 create-target-group --name $8 --protocol HTTP --port 80 --target-type instance --vpc-id $VPCID --no-cli-pager --query="TargetGroups[*].TargetGroupArn")

############################################
# Register Target with created Target Group
############################################
echo "Attaching EC2 targets to Target Group..."

# Assign the values of $EC2IDS and places each element (seperated by a space) into an array element
EC2IDSARRAY=($EC2IDS)

for EC2ID in ${EC2IDSARRAY[@]};
do
aws elbv2 register-targets --target-group-arn $TGARN --targets Id=$EC2ID
done
echo "Targets are registered to Target Group"

#######################
# Create Load Balancer
#######################
echo "Creating Load Balancer $7 ..."

ELBARN=$(aws elbv2 create-load-balancer --security-groups $4 --name $7 --subnets $SUBNET1 $SUBNET2 --security-groups $4 --no-cli-pager --query='LoadBalancers[*].LoadBalancerArn')

##################################
# Wait Load Balancer to be active
##################################
echo "Waiting for Load Balancer to be active..."

aws elbv2 wait load-balancer-available \
    --load-balancer-arns $ELBARN \
    --no-cli-pager

echo "Load Balancer is active & Available"
################################################################################################
# Create Listener
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/create-listener.html
################################################################################################
echo "Creating Listener..."

aws elbv2 create-listener \
    --load-balancer-arn $ELBARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TGARN \
    --no-cli-pager

# aws elbv2 describe-load-balancers -- retrieve the URL

URL=$(aws elbv2 describe-load-balancers --output=text --load-balancer-arns $ELBARN --no-cli-pager --query='LoadBalancers[*].DNSName')

echo 'URL ===> ' $URL