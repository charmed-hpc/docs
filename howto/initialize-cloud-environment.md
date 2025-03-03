---
relatedlinks: "[Get&#032;started&#032;with&#032;Juju](https://juju.is/docs/juju/tutorial), [Juju&#032;(Application)](https://juju.is/docs/juju/application), [Juju&#032;(Charm)](https://juju.is/docs/juju/charmed-operator), [Juju&#032;(Cloud)](https://juju.is/docs/juju/cloud), [Juju&#032;(Controller)](https://juju.is/docs/juju/controller)"
---

(howto-initialize-cloud-environment)=
# How to initialize cloud environment

This how-to guide shows you how to initialize the cloud environment where you will
deploy your Charmed HPC cluster.

Charmed HPC uses a converged architecture where a machine cloud hosts compute plane
applications like the cluster's workload manager and filesystem, and a Kubernetes (K8s) cloud
hosts common control plane applications like identity management and observability services.
It is __strongly recommended__ that you pair your machine cloud with a complimenting Kubernetes cloud
to simplify the deployment and management of both clouds. For example, LXD should be paired
with Canonical Kubernetes, Azure paired with AKS, AWS paired with EKS, and so on.

:::{note}
To Charmed HPC, a __cloud__ (or ___backing cloud___) is any entity that has an API that can
provide compute, networking, and optionally storage resources to applications deployed on them.
This includes public clouds such as Amazon Web Services, Google Compute Engine, Microsoft Azure
and Kubernetes as well as private OpenStack-based clouds. Charmed HPC can also make use of
environments, such as MAAS and LXD, which are not necessarily considered clouds, but can be treated
as a cloud.
:::

## Prerequisites

To initialize the cloud environment where you will deploy your Charmed HPC cluster,
you will need:

* Access to a [supported machine cloud](https://canonical-juju.readthedocs-hosted.com/en/latest/user/reference/cloud/list-of-supported-clouds/)
* Access to a [supported Kubernetes cloud](https://canonical-juju.readthedocs-hosted.com/en/latest/user/reference/cloud/list-of-supported-clouds/)
* The [Juju CLI client](https://canonical-juju.readthedocs-hosted.com/en/latest/user/howto/manage-juju/) installed on your machine

(howto-initialize-machine-cloud)=
## Initialize machine cloud

Follow the instructions below to initialize the `charmed-hpc` machine cloud.

:::::{tab-set}

::::{tab-item} LXD
:sync: lxd

### Prerequisites for LXD

To use LXD as the machine cloud for your Charmed HPC cluster, you will need to have:

* [Installed LXD](https://documentation.ubuntu.com/lxd/en/stable-5.21/installing/)
* [Initialized LXD](https://documentation.ubuntu.com/lxd/en/stable-5.21/howto/initialize/)
* [Exposed LXD to the network](https://documentation.ubuntu.com/lxd/en/stable-5.21/howto/server_expose/)
* [Configured a server trust password](https://documentation.ubuntu.com/lxd/en/stable-5.21/server/#server-core:core.trust_password)

:::{hint}
If you're unfamiliar with operating an LXD server, see the [First steps with LXD](https://documentation.ubuntu.com/lxd/en/latest/tutorial/first_steps/)
tutorial for a high-level introduction to LXD.
:::

### Add LXD cloud to Juju

To make your LXD cloud known to Juju, first create the file _charmed-hpc-cloud.yaml_ and enter the following
content, substituting `<public address of lxd server>` with the public address of your LXD server:

:::{code-block} yaml
:caption: `charmed-hpc-cloud.yaml`
:linenos:

clouds:
  charmed-hpc:
    type: lxd
    description: "Machine cloud for Charmed HPC"
    auth-types: [certificate, interactive]
    endpoint: <public address of lxd server>
:::

Now, after creating _charmed-hpc-cloud.yaml_, use `juju add-cloud`{l=shell} to add
your LXD cloud to Juju:

:::{code-block} shell
juju add-cloud charmed-hpc --file ./charmed-hpc-cloud.yaml
:::

### Add LXD cloud credentials to Juju

Before you can start deploying applications on your LXD server, you must add credentials for contacting
your LXD server to Juju. Create the file _charmed-hpc-cloud-credentials.yaml_ and enter the following content, with
`<lxd server trust password>` substituted with your LXD server's configured trust password:

:::{code-block} yaml
:caption: `charmed-hpc-cloud-credentials.yaml`
:linenos:

credentials:
  charmed-hpc:
    accesskey:
      auth-type: interactive
      trust-password: <lxd server trust password>
:::

Now use `juju add-credential`{l=shell} to add the credentials for contacting your LXD server to Juju:

:::{code-block} shell
juju add-credential charmed-hpc --file ./charmed-hpc-cloud-credentials.yaml
:::

:::{note}
Juju will use your LXD server's configured trust password to automatically retrieve your server's TLS certificates.
:::

### Bootstrap LXD cloud controller

With both your LXD server's endpoint and credentials added to Juju, use `juju bootstrap`{l=shell} to deploy
the cloud controller:

:::{code-block} shell
juju bootstrap charmed-hpc charmed-hpc-controller
:::

After a few minutes, your LXD cloud controller will become active. The output of `juju status`{l=shell}
command should be similar to the following:

:::{terminal}
:input: juju status -m controller

Model       Controller              Cloud/Region         Version  SLA          Timestamp
controller  charmed-hpc-controller  charmed-hpc/default  3.6.2    unsupported  13:55:33-05:00

App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
controller           active      1  juju-controller  3.6/stable  116  no

Unit           Workload  Agent  Machine  Public address  Ports  Message
controller/0*  active    idle   0        10.190.89.114

Machine  State    Address        Inst id        Base          AZ  Message
0        started  10.190.89.114  juju-3b4cde-0  ubuntu@24.04      Running
:::

::::

::::{tab-item} Azure
:sync: azure

To use Microsoft Azure as the machine cloud for your Charmed HPC cluster, you will need to have:

* [A valid Azure subscription ID](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id)
* [Installed the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux)
* [Signed into the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)
* [Adjusted quotas for suitable virtual machine (VM) families](https://learn.microsoft.com/en-us/azure/quotas/per-vm-quota-requests)

:::{hint}
To decide on suitable VMs, it may be useful to refer to [Sizes for virtual machines in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview). A typical Charmed HPC deployment will use a mix of high-performance and GPU-accelerated compute VMs for cluster compute nodes, and general purpose VMs for other node types.
:::

### Add Azure cloud to Juju

:::{note}
Azure supports a variety of authentication workflows with Juju. These instructions provide only a single example of creating a Service Principal to enable Juju to automatically create a Managed Identity. Refer to [the Juju documentation](https://canonical-juju.readthedocs-hosted.com/en/latest/user/reference/cloud/list-of-supported-clouds/the-microsoft-azure-cloud-and-juju/) for full details on authentication with Azure and **ensure you choose a method which meets requirements for security in your environment**.
:::

To make your Azure credentials known to Juju, run:

:::{code-block} shell
juju add-credential azure
:::

This will start a script where you will be asked:

* `credential-name` — your choice of name that will help you identify the credential set, referred to as `<CREDENTIAL_NAME>` hereafter.
* `region` — a default region that is most convenient to deploy your controller and applications. Note that credentials are not region-specific.
* `auth type` — authentication type. Select `interactive`, the recommended way to authenticate to Azure using Juju.
* `subscription_id` — your Azure subscription ID, typical format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`, referred to as `<SUBSCRIPTION_ID>` hereafter.
* `application_name` (optional) — any unique string to avoid collision with other users or applications. Leave blank to let the script decide.
* `role-definition-name` (optional) — any unique string to avoid collision with other users or applications, referred to as <AZURE_ROLE> hereafter. Leave blank to let the script decide.

You will be asked to authenticate the requests via your web browser with the following message:

:::{code-block} shell
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code <AUTHCODE> to authenticate.
:::

In a web browser, open the [authentication page](https://microsoft.com/devicelogin), sign in as required, and enter `<AUTHCODE>` from the terminal output.

You will be asked to authenticate twice, to allow creation of two different resources in Azure.

Once the credentials have been added successfully, the following message will be displayed:

:::{code-block} shell
Credential <CREDENTIAL_NAME> added locally for cloud "azure".
:::

### Widen scope for credentials

To allow Juju to automatically create resources in Azure, further privileges should be granted to the credentials created above. Run:

:::{terminal}
:input: juju show-credentials azure <CREDENTIAL_NAME>

client-credentials:
  azure:
    <CREDENTIAL_NAME>:
      content:
        auth-type: service-principal-secret
        application-id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        application-object-id: yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy
        subscription-id: <SUBSCRIPTION_ID>
:::

substituting `<CREDENTIAL_NAME>` with your credential name. Copy the value of `application-object-id:` and run:

:::{code-block} shell
az role assignment create --assignee <APPLICATION_OBJECT_ID> --role Owner --scope /subscriptions/<SUBSCRIPTION_ID>
:::

substituting `<APPLICATION_OBJECT_ID>` with the value of `application-object-id:` and `<SUBSCRIPTION_ID>` with your Azure subscription ID.

:::{note}
This will grant the credential "full access to manage all resources". Refer to [Azure built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) for further details on the Owner role and other available roles.
:::

### Bootstrap Azure cloud controller

First, set the default region for deploying Azure instances, including the controller itself. Refer to [What are Azure regions?](https://learn.microsoft.com/en-us/azure/reliability/regions-overview) for an overview of available regions. To set the default region to East US:

:::{code-block} shell
juju default-region azure eastus
:::

Then bootstrap with:

:::{code-block} shell
juju bootstrap azure --constraints "instance-role=auto"
:::

After a few minutes, your Azure cloud controller will become active. The output of juju status command should be similar to the following:

:::{terminal}
:input: juju status -m controller

Model       Controller    Cloud/Region  Version  SLA          Timestamp
controller  azure-eastus  azure/eastus  3.6.3    unsupported  14:38:21Z

App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
controller           active      1  juju-controller  3.6/stable  116  no

Unit           Workload  Agent  Machine  Public address  Ports  Message
controller/0*  active    idle   0        x.x.x.x

Machine  State    Address      Inst id        Base          AZ  Message
0        started  x.x.x.x      juju-e63b38-0  ubuntu@24.04
:::

### Clean up

:::{note}
Always clean Azure resources that are no longer necessary! Abandoned resources are tricky to detect and they can become expensive over time.
:::

To list all controllers that have been registered to your local client, use the `juju controllers` command.

To destroy the Juju controller and remove the Azure instance (Warning: all your data will be permanently removed):

:::{code-block} shell
juju destroy-controller <CONTROLLER_NAME> --destroy-all-models --destroy-storage --force
:::

Should the destroying process take a long time or be seemingly stuck, proceed to delete VM resources also manually via the Azure portal. See [Azure documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resources-portal) for more information on how to remove active resources no longer needed.

Next, check and manually delete all unnecessary Azure VM instances, to show the list of all your Azure VMs run the following command (make sure to use the correct region):

:::{code-block} shell
az resource list
:::

List your Juju credentials with:

:::{terminal}
:input: juju credentials

Client Credentials:
Cloud        Credentials
azure        <CREDENTIAL_NAME>
:::

Remove Azure CLI credentials from Juju:

:::{code-block} shell
juju remove-credential azure <CREDENTIAL_NAME>
:::

After deleting the credentials, the interactive process may still leave the role resource and its assignment hanging around. It is recommend to check if these are still present by running:

:::{code-block} shell
az role definition list --name <AZURE_ROLE>
:::

To get the full list of all roles, run the command without specifying the `--name` parameter.

It is possible to check whether a role assignment is still bound to `<AZURE_ROLE>` by:

:::{code-block} shell
az role assignment list --role <AZURE_ROLE>
:::

If there is an unwanted role left, the role assignment should be removed first and then the role itself with the following commands:

:::{code-block} shell
az role assignment delete --role <AZURE_ROLE>
az role definition delete --name <AZURE_ROLE>
:::

Finally, log out from Azure CLI:

:::{code-block} shell
az logout
:::

::::

:::::

(howto-initialize-kubernetes-cloud)=
## Initialize Kubernetes cloud

After initializing the `charmed-hpc` machine cloud, follow the instructions below to initialize the
`charmed-hpc-k8s` Kubernetes cloud.

:::::{tab-set}

::::{tab-item} Canonical Kubernetes
:sync: lxd

### Prerequisites for Canonical Kubernetes

To use Canonical Kubernetes as the Kubernetes cloud for your Charmed HPC cluster,
you will need to have:

* [Initialized a machine cloud](#howto-initialize-machine-cloud)
* [Installed and bootstrapped Canonical Kubernetes](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/install/snap/)
* [Enabled the default load balancer](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-loadbalancer/)

:::{hint}
If you're unfamiliar with operating a Canonical Kubernetes cluster, see the
[Canonical Kubernetes tutorials](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/)
for a high-level introduction to Canonical Kubernetes.
:::

### Add Canonical Kubernetes cloud to deployed controller

To make your Canonical Kubernetes cloud known to Juju and use the same controller as your
machine cloud, pipe the output of `k8s config`{l=shell} to `juju add-k8s`{l=shell} by running the
following command:

:::{code-block} shell
sudo k8s config | \
  juju add-k8s --controller charmed-hpc-controller charmed-hpc-k8s
:::

`juju add-k8s`{l=shell} will immediately add your Canonical Kubernetes cloud to the controller of your machine
cloud. The output of `juju clouds`{l=shell} should be similar to the following:

:::{terminal}
:input: juju clouds --controller charmed-hpc-controller


Clouds available on the controller:
Cloud            Regions  Default  Type
charmed-hpc      1        default  lxd
charmed-hpc-k8s  1        default  k8s
:::

::::

:::::

## Next Steps

Now that both the `charmed-hpc` machine cloud and `charmed-hpc-k8s` Kubernetes cloud are initialized,
you can start deploying applications with Juju. Go to the {ref}`howto-setup-deploy-slurm` guide
for how to deploy Slurm as the workload manager of your Charmed HPC cluster.
