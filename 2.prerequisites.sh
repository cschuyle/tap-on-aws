#!/bin/bash
set -e
set -o pipefail
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/functions.sh"

banner "Deploying kapp-controller"
set -x
kapp deploy -y -a kc -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml -y
kubectl get deployment kapp-controller -n kapp-controller  -o yaml | grep kapp-controller.carvel.dev/version
set +x

banner "Deploying secretgen-controller"
set -x
kapp deploy -a sg -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/latest/download/release.yml -y
kubectl get deployment secretgen-controller -n secretgen-controller -o yaml | grep secretgen-controller.carvel.dev/version:
kubectl get pods -A | grep secretgen-controller
set +x

banner "Deploying cert-manager"
set -x
kapp deploy -a cert-manager -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml -y
kubectl get deployment cert-manager -n cert-manager -o yaml | grep -m 1 'app.kubernetes.io/version: v'
set +x