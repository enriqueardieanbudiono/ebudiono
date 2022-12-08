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

#####################
# Create db instance
#####################

echo "Creating db instance with identifier ${11}"

aws rds create-db-instance \
    --db-instance-identifier ${11} \
    --db-instance-class db.t3.micro \
    --engine mariadb \
    --master-username wizard \
    --master-user-password cluster168 \
    --allocated-storage 20 \
    --no-cli-pager

echo "db instance created"

echo "Waiting for db instance to be available"

aws rds wait db-instance-available \
    --db-instance-identifier ${11} \
    --no-cli-pager

echo "${11} database is active & available"

echo "Creating db instance read replica with identifier ${12}"

aws rds create-db-instance-read-replica \
    --db-instance-identifier ${12} \
    --source-db-instance-identifier ${11} \
    --no-cli-pager

echo "db instance read replica created"

echo "Waiting for db instance read replica to be available"

aws rds wait db-instance-available \
    --db-instance-identifier ${12} \
    --no-cli-pager

echo "${12} database read replica is active & available"

##################################################################################################################
# Create Launch Configuration
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/autoscaling/create-launch-configuration.html
##################################################################################################################

echo "Creating Launch Configuration ${10}..."

aws autoscaling create-launch-configuration --launch-configuration-name ${10} --image-id $1 --instance-type $2 --key-name $3 --security-groups $4 --user-data file://install-env.sh --no-cli-pager

echo "Launch Configuration ${10} created."

######################
# Create Target Group
######################

echo "Creating Target Group $8 ...."

TGARN=$(aws elbv2 create-target-group --name $8 --protocol HTTP --port 80 --target-type instance --vpc-id $VPCID --no-cli-pager --query="TargetGroups[*].TargetGroupArn")

#################################
# Create AWS elbv2 load-balancer
#################################

echo "Creating load-balancer $7 ..."

ELBARN=$(aws elbv2 create-load-balancer --security-groups $4 --name $7 --subnets $SUBNET1 $SUBNET2 --no-cli-pager --query='LoadBalancers[*].LoadBalancerArn')

# Waiting for Load-balancer
echo "Waiting for Load Balancer to be active..."

aws elbv2 wait load-balancer-available \
    --load-balancer-arns $ELBARN \
    --no-cli-pager

echo "Load-balancer $7 active & available."

################################################################################################
# Create Listener
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/create-listener.html
################################################################################################

echo "Creating Listener for load-balancer $7 ..."

aws elbv2 create-listener \
    --load-balancer-arn $ELBARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TGARN \
    --no-cli-pager

echo "Listener created."

################################################################################################################
# Create autoscaling group
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/autoscaling/create-auto-scaling-group.html
################################################################################################################

echo "Launch configuration name is: ${10}"

aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name ${9} \
    --launch-configuration-name ${10} \
    --min-size ${13} \
    --max-size ${14} \
    --desired-capacity ${15} \
    --target-group-arns $TGARN \
    --health-check-type ELB \
    --health-check-grace-period 600 \
    --availability-zones $6 \
    --no-cli-pager

echo "Auto Scaling Group ${9} created."
########################################################
# aws elbv2 describe-load-balancers -- retrieve the URL
########################################################

URL=$(aws elbv2 describe-load-balancers --output=text --load-balancer-arns $ELBARN --no-cli-pager --query='LoadBalancers[*].DNSName')

echo 'URL ===> ' $URL