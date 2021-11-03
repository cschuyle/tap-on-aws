#!/bin/bash
set -e
set -o pipefail
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/functions.sh"

cat <<EOF

This script installs Tanzu Application Platform (TAP) into an AWS EKS cluster.
You shoudl read the README.md before embarking upon this.

EOF

findOrPrompt TAP_VERSION "TAP version number"

findOrPrompt TN_USERNAME "Tanzu Network Username"
findOrPrompt TN_PASSWORD "Tanzu Network Password (will be echoed)"

cat <<EOT

The container registry should be something like 'myuser/tap' for DockerHub or
'harbor-repo.example.com/myuser/tap' for an internal registry.

EOT
findOrPrompt REGISTRY "Container Registry"
findOrPrompt REG_USERNAME "Registry Username"
findOrPrompt REG_PASSWORD "Registry Password (will be echoed)"

banner "Creating tap-install namespace"

(kubectl get ns tap-install 2> /dev/null) || \
  kubectl create ns tap-install

banner "Creating tap-registry secret"

tanzu secret registry delete tap-registry --namespace tap-install -y || true
waitForRemoval kubectl get secret tap-registry --namespace tap-install -o json

tanzu secret registry add tap-registry \
  --username "$TN_USERNAME" --password "$TN_PASSWORD" \
  --server registry.tanzu.vmware.com \
  --export-to-all-namespaces \
  --namespace tap-install \
  -y

banner "Removing any current TAP package repository"

tanzu package repository delete tanzu-tap-repository -n tap-install -y || true
waitForRemoval tanzu package repository get tanzu-tap-repository -n tap-install -o json

banner "Adding TAP package repository"

tanzu package repository add tanzu-tap-repository \
    --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:$TAP_VERSION \
    --namespace tap-install
tanzu package repository get tanzu-tap-repository --namespace tap-install
while [[ $(tanzu package available list --namespace tap-install -o json) == '[]' ]]
do
  message "Waiting for packages ..."
  sleep 5
done

banner "Creating tap-values.yaml"
rm -f tap-values.yaml
cat > tap-values.yaml <<EOF
profile: dev-light

install_cert_manager: false

buildservice:
  # e.g. us-east4-docker.pkg.dev/some-project-id/test-private-repo/apps
  kp_default_repository: "$REGISTRY"
  kp_default_repository_username: "$REG_USERNAME"
  kp_default_repository_password: "$REG_PASSWORD"
  tanzunet_username: "$TN_USERNAME"
  tanzunet_password: "$TN_PASSWORD"

ootb_supply_chain_basic:
  registry:
    # Name of the registry server where application images should be pushed to (default index.docker.io)
    # e.g. us-east4-docker.pkg.dev
    server: index.docker.io
    # Name of the repository in the image registry server where the application images from the workloads should be pushed to (required)
    # e.g. some-project-id/test-private-repo/apps
    repository: "$REGISTRY"

tap_gui:
  service_type: LoadBalancer
EOF

LEFT OFF HERE: registry.server

banner "Removing any existing k8s objects or tanzu packages"

(kubectl delete serviceaccount tap-tap-install-sa -n tap-install || true)
(kubectl delete clusterrole tap-tap-install-cluster-role || true)
(kubectl delete clusterrolebinding tap-tap-install-cluster-rolebinding || true)
(kubectl delete secret tap-tap-install-values -n tap-install || true)
(tanzu package installed delete tap -n tap-install -y || true)

banner "Installing tap package"

tanzu package install tap -p tap.tanzu.vmware.com -v "$TAP_VERSION" --values-file tap-values.yaml -n tap-install

# Two packages of interest that are not in dev-light: api portal and app-accelerator

banner "Installing api-portal package"
(tanzu package installed delete api-portal -n tap-install -y || true)
tanzu package install api-portal -p api-portal.tanzu.vmware.com -v 1.0.3 -n tap-install

banner "Installing app accelerator package"
(tanzu package installed delete app-accelerator -n tap-install -y || true)
tanzu package install app-accelerator -p accelerator.apps.tanzu.vmware.com -v 0.4.0 -n tap-install
