#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail

function findOrPrompt() {
  local varName="$1"
  local prompt="$2"

  if [[ -z "${!varName}" ]]
  then
    read -p "$prompt: " $varName
  else
    echo "Value for $varName found in environment"
  fi
}

findOrPrompt AWS_REGION "AWS REGION"
findOrPrompt EKS_CLUSTER_NAME "EKS cluster name (the name of the existing cluster)"

eksctl delete cluster --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"
