# TAP on AWS

_This repo borrows heavily from Neil Winton's <https://github.com/ndwinton/tap-setup-scripts>._

Automate the installation of Tanzu Application Platform (TAP) running on AWS EKS (Elastic Kubernetes Service)

The scripts attempt to automate the install instructions:
<https://docs-staging.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-install-intro.html>

This was done after the release of 0.3.0-build.6

## 1. Prerequisites

The Tanzu-specific prerequisites are too numerous and detailed to repeat, and are specified in detail here:
<https://docs-staging.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-install-intro.html>
You should read and follow the prerequisites first.

The TL;DR is:

Tools installed on your local machine (Tanzu-specific, AWS-specific, and other):
- `aws` CLI
- `kubeconfig` Kubernetes CLI
- The latest version of the `tanzu` CLI (which is different from the latest non-beta one), with various plugins
- The Carvel tool set (`kapp` and friends): <https://carvel.dev/>
- `jq`: <https://stedolan.github.io/jq/>
- `eksctl`: <https://eksctl.io/>

Aside from tools, you'll need:
- A Tanzu Network account
- An AWS account with an IAM user with the ability to create an EKS cluster with 4 EC2 instances of type `t2.xlarge`
- An external image repository account (e.g. DockerHub)
 
## 2. (Optional) Set your environment variables

If you wish to store your environment variables locally in order to avoid entering them at the prompts
(e.g. in `.envrc`, if you use `direnv`), then copy `envrc-template` to a new file called `.envrc`,
edit the new file, and `direnv allow` it.

Of course, you can use the template file as documentation to set your environment variables by whatever
mechanism you choose.   

You might need to read forward a little bit to figure out what all the values are.

```bash
cp envrc-template .envrc
# Edit .envrc to contain the correct values. Make sure to use enclose values with shell special characters, like `!`, with single quotes
direnv allow
```

## 3. Configure (log into) `aws`

```bash
aws configure
```
Follow the prompts, filling in your AWS IAM's credentials.

## 4a. Create an EKS cluster on AWS

**To create a brand-new cluster:**

```bash
./create-eks-cluster.sh
```
If you have not set all the required environment variables, then you will be prompted for the values.

If successful, this should take approximately 20 minutes.

Note that this step modifies your `~/.kube/config` file to contain a Kubernetes Context that points to the new cluster,
and also sets the current context to it.  You can verify that by typing:

```
kubectl config get-contexts
```

4b. Use an existing EKS cluster

**To connect to an existing cluster:**

_NOTE: For instructions on how to grant permissions to a cluster for a new user, see this: <https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html>_

Navigate the AWS Console Elastic Kubernetes Service page, click on *Clusters*, and find the name of the cluster
you want to install TAP into. Then:
```
aws eks update-kubeconfig <CLUSTER_NAME>
```

## 5. Install TAP in the EKS cluster

Execute the following scripts in order:
```
./1.install-tanzu-cli.sh
./2.prerequisites.sh
./3.setup-tap.sh
```
If you have not set all the required environment variables, then you will be prompted for the values.

Sit back and relax ... If successful, the entire installation process should take approximately 20 minutes.


## 6. [Exercise some TAP functionality](./doc/USING_TAP.md)

## 7. (Optional) Destroy the cluster

If you are sensitive to cost, when you do not need the TAP installation, you can destroy the entire AWS EKS cluster:

```
./delete-eks-cluster.sh
```
