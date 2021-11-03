
cat <<EOF
This Script is not meant to be executed, it's just rough notes.
You should read through it and install the correct version of the tanzu CLI.
EOF

exit 0

# Go to https://network.tanzu.vmware.com/products/tanzu-application-platform/#/releases/989527/file_groups/5782

# Download the version you want.  Go to the Downloads directory.
tar -xvf tanzu-framework-linux-amd64.tar -C $HOME/tanzu
cd $HOME/tanzu
sudo install cli/core/v0.9.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu version

tanzu plugin list

# If there are upgrades to be had, do them - I had these:
tanzu plugin upgrade cluster
tanzu plugin upgrade kubernetes-release
tanzu plugin upgrade login
tanzu plugin upgrade management-cluster
# I got this warning installing package:
# !  Warning: Failed to initialize plugin '"package"' after installation.
# so I deleted then installed, no errors.
tanzu plugin upgrade package
tanzu plugin upgrade pinniped-auth
# Secret behaved the same as package
tanzu plugin upgrade secret

# In all of the plugin updates, if you get this:
#
#   Error: could not fetch manifest from repository "core": Get "https://storage.googleapis.com/tanzu-cli-framework/artifacts/manifest.yaml": context deadline exceeded
#
# Try again until it works.

# Here are the plugin versions I ended up with:
#
#NAME                LATEST VERSION  DESCRIPTION                                                        REPOSITORY  VERSION  STATUS
#accelerator                         Manage accelerators in a Kubernetes cluster                                    v0.4.1   installed
#apps                                Applications on Kubernetes                                                     v0.2.0   installed
#cluster             v0.9.0          Kubernetes cluster operations                                      core        v0.9.0   installed
#kubernetes-release  v0.9.0          Kubernetes release operations                                      core        v0.9.0   installed
#login               v0.9.0          Login to the platform                                              core        v0.9.0   installed
#management-cluster  v0.9.0          Kubernetes management cluster operations                           core        v0.9.0   installed
#package             v0.9.0          Tanzu package management                                           core        v0.9.0   installed
#pinniped-auth       v0.9.0          Pinniped authentication operations (usually not directly invoked)  core        v0.9.0   installed
#secret              v0.9.0          Tanzu secret management                                            core        v0.9.0   installed


