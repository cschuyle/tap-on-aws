#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail

set -x

## From: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.2/tap-0-2/GUID-install.html


set +x
echo set the TAP_CONTEXT environment variable to the proper name from the below list, and export it:
echo
echo export TAP_CONTEXT=context-name
echo
set -x

kubectl config get-contexts
