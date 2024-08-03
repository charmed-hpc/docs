---
relatedlinks: "[Get&#32;started&#32;with&#32;COS](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s)"
---

(connect-workload-manager-to-cos)=
# How to connect your cluster's workload manager to COS

This how-to guide shows you how to connect your cluster's
workload manager to the Canonical Observability Stack to observe
the workload manager's logs, metrics, and a alerts.

## Prerequisites

To successfully connect your cluster's workload manager to COS, you must have:

- [A deployed COS cloud.](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s)
- {ref}`A deployed workload manager. <deploy-workload-manager>`
- The [Juju CLI client](https://juju.is/docs/juju/install-and-manage-the-client) installed on your machine.

## Deploy an agent

First, in the model hosting your Charmed HPC cluster's workload manager,
deploy a Grafana agent:

```shell
juju deploy grafana-agent
```

## Connect the workload manager to the agent

After deploying the Grafana agent, connect the agent to the
workload manager controller:

```shell
juju integrate slurmctld:cos-agent grafana-agent:cos-agent
```

## Make COS available to the workload manager

With the agent connected to the workload manager controller, make COS available
to the model hosting the cluster's workload manager:

```{important}
For the instructions below to succeed, you must have deployed the
[`offers` overlay](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s#heading--deploy-the-cos-lite-bundle-with-overlays)
as part of your COS cloud deployment.
```

```shell
juju consume microk8s:admin/cos.prometheus-receive-remote-write
juju consume microk8s:admin/cos.loki-logging
juju consume microk8s:admin/cos.grafana-dashboards
```

## Connect the workload manager to COS

Now connect the Grafana agent connected to the workload manager controller to
COS:

```shell
juju relate grafana-agent prometheus-receive-remote-write
juju relate grafana-agent loki-logging
juju relate grafana-agent grafana-dashboards
```
