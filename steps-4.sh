#!/usr/bin/env bash
set -o errexit # set -e
set -o pipefail

# TODO I think this can be put back in step 3; there is no user interaction here.
rm -f default-supply-chain-values.yaml
cat << EOF > default-supply-chain-values.yaml
---
registry:
  server: $REGISTRY_SERVER
  repository: $REPOSITORY
service_account: service-account
EOF

tanzu package install default-supply-chain \
 --package-name default-supply-chain.tanzu.vmware.com \
 --version 0.2.0 \
 --namespace tap-install \
 --values-file default-supply-chain-values.yaml

tanzu package install developer-conventions \
  --package-name developer-conventions.tanzu.vmware.com \
  --version 0.2.0 \
  --namespace tap-install

kubectl create ns app-live-view

# TODO Should we add namespaces besides default where the connector will run?
rm -f app-live-view-values.yaml
cat > app-live-view-values.yaml << EOF
---
connector_namespaces: [default]
server_namespace: app-live-view
EOF

# TODO guard against expensive mistakes by checking that the file exists before running the following.
tanzu package install app-live-view -p appliveview.tanzu.vmware.com -v 0.2.0 -n tap-install -f app-live-view-values.yaml

tanzu package install service-bindings -p service-bindings.labs.vmware.com -v 0.5.0 -n tap-install

tanzu package available get scst-store.tanzu.vmware.com/1.0.0-beta.0 --values-schema -n tap-install

rm -f scst-store-values.yaml
cat > scst-store-values.yaml << EOF
db_password: "$DB_PASSWORD"
app_service_type: LoadBalancer
db_host: metadata-store-db
EOF

tanzu package install metadata-store \
  --package-name scst-store.tanzu.vmware.com \
  --version 1.0.0-beta.0 \
  --namespace tap-install \
  --values-file scst-store-values.yaml

rm -f scst-sign-values.yaml
cat > scst-sign-values.yaml << EOF
---
warn_on_unmatched: true
EOF

tanzu package install image-policy-webhook \
  --package-name image-policy-webhook.signing.run.tanzu.vmware.com \
  --version 1.0.0-beta.0 \
  --namespace tap-install \
  --values-file scst-sign-values.yaml

# TODO: Continue at step 5 (Create a service account named registry-credentials in the image-policy-system namespace. )
# of: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.2/tap-0-2/GUID-install.html#install-supply-chain-security-tools--store-15
