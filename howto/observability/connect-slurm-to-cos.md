---
relatedlinks: "[Get&#32;started&#32;with&#32;COS](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s)"
---

(connect-slurm-to-cos)=
# How to connect Slurm to COS

This how-to guide shows you how to connect Slurm to the
Canonical Observability Stack (COS) to monitor and observe a deployed Slurm cluster.

## Prerequisites

To successfully connect Slurm to COS, you must have:

- [A deployed COS cloud.](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s)
- {ref}`A deployed Slurm cluster. <deploy-slurm>`
- The [Juju CLI client](https://juju.is/docs/juju/install-and-manage-the-client) installed on your machine.

## Deploy the Grafana Agent

First, in the model holding your Slurm deployment, deploy a Grafana Agent:

:::{code-block} shell
juju deploy grafana-agent
:::

## Connect Slurm to Grafana Agent

After deploying the Grafana Agent, connect the agent to the Slurm controller:

:::{code-block} shell
juju integrate slurmctld:cos-agent grafana-agent:cos-agent
:::

## Make COS available to Slurm via a cross-model offer

With Grafana Agent deployed to the same machine as the Slurm controller,
make COS available to the model holding your Slurm deployment:

:::{important}
For the instructions below to succeed, you must have deployed the
[`offers` overlay](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s#heading--deploy-the-cos-lite-bundle-with-overlays)
as part of your COS cloud deployment.
:::

:::{code-block} shell
juju consume microk8s:admin/cos.prometheus-receive-remote-write
juju consume microk8s:admin/cos.loki-logging
juju consume microk8s:admin/cos.grafana-dashboards
:::

## Connect the workload manager to COS

Now connect the Grafana Agent connected to the workload manager controller to
COS:

:::{code-block} shell
juju integrate grafana-agent prometheus-receive-remote-write
juju integrate grafana-agent loki-logging
juju integrate grafana-agent grafana-dashboards
:::
