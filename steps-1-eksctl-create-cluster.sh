#!/usr/bin/env bash
#set -o errexit # set -e
#set -o pipefail
#script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#script_file=$(basename "$0")

## FROM: https://www.youtube.com/watch?v=p6xDCz00TxU

set -x

name=mapbu-services-strategy
instance_type=t2.xlarge # 4 CPUs, 16G RAM, 80G storage
node_count=4

eksctl create cluster \
--name $name-cluster \
--version 1.21 \
--region us-east-2 \
--nodegroup-name worker-nodes \
--node-type $instance_type \
--nodes $node_count
