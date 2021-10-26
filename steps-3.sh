#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail

kubectl config use-context ${TAP_CONTEXT}

kapp -y deploy -a kc -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.28.0/release.yml

kapp -y deploy -a sg -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v0.5.0/release.yml

kapp -y deploy -a cert-manager -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml

kubectl create namespace flux-system

kubectl create clusterrolebinding default-admin \
--clusterrole=cluster-admin \
--serviceaccount=flux-system:default

kapp -y deploy -a flux-source-controller -n flux-system \
-f https://github.com/fluxcd/source-controller/releases/download/v0.15.4/source-controller.crds.yaml \
-f https://github.com/fluxcd/source-controller/releases/download/v0.15.4/source-controller.deployment.yaml


kubectl create ns tap-install

## Packages

tanzu imagepullsecret add tap-registry \
  --username "${TANZU_NET_USER}" --password "${TANZU_NET_PASSWORD}" \
  --registry registry.tanzu.vmware.com \
  --export-to-all-namespaces --namespace tap-install

tanzu package repository add tanzu-tap-repository \
    --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:0.2.0 \
    --namespace tap-install

 tanzu package repository get tanzu-tap-repository --namespace tap-install

## Packages

# TODO Use cat > << EOF instead of files even if there are no fill-ins. And gitignore all of them.
tanzu package install cloud-native-runtimes -p cnrs.tanzu.vmware.com -v 1.0.2 -n tap-install -f cnr-values.yaml --poll-timeout 30m

# NOTE: Skipped "6. Configuring a namespace to use Cloud Native Runtimes:" because elected to do "Set Up Developer Namespaces to Use Installed Packages" instead.

tanzu package install app-accelerator -p accelerator.apps.tanzu.vmware.com -v 0.3.0 -n tap-install -f app-accelerator-values.yaml

tanzu package install convention-controller -p controller.conventions.apps.tanzu.vmware.com -v 0.4.2 -n tap-install

tanzu package install source-controller -p controller.source.apps.tanzu.vmware.com -v 0.1.2 -n tap-install

tanzu package available get buildservice.tanzu.vmware.com/1.3.0 --values-schema --namespace tap-install

rm -f tbs-values.yaml
cat << EOF > tbs-values.yaml
---
kp_default_repository: $REPOSITORY
kp_default_repository_username: $REGISTRY_USERNAME
kp_default_repository_password: $REGISTRY_PASSWORD
tanzunet_username: $TANZU_NET_USER
tanzunet_password: $TANZU_NET_PASSWORD
EOF

tanzu package install tbs -p buildservice.tanzu.vmware.com -v 1.3.0 -n tap-install -f tbs-values.yaml --poll-timeout 30m

set +x
echo set the REGISTRY_SERVER and REGISTRY_REPOSITORY environment variables to the proper name from the below list, and export it:
echo
echo export REGISTRY_SERVER=context-name
echo export REGISTRY_REPOSITORY=context-name
echo
set -x

tanzu package available get default-supply-chain.tanzu.vmware.com/0.2.0 --values-schema -n tap-install
