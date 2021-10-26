#!/usr/bin/env bash
#set -o errexit # set -e
#set -o pipefail
#script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#script_file=$(basename "$0")

set -x

name=mapbu-services-strategy
role_name=$name-role
region=us-west-2

aws cloudformation create-stack \
  --region $region \
  --stack-name $name-stack \
  --template-url https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml

aws iam create-role \
  --role-name $role_name \
  --assume-role-policy-document file://"cluster-role-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name $role_name

