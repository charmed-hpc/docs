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

* Access to a [supported machine cloud](https://juju.is/docs/juju/juju-supported-clouds)
* Access to a [supported Kubernetes cloud](https://juju.is/docs/juju/juju-supported-clouds)
* The [Juju CLI client](https://juju.is/docs/juju/install-and-manage-the-client) installed on your machine

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

:::::

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
