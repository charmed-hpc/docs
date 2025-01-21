---
relatedlinks: "[Get&#32;started&#32;with&#32;COS](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s)"
---

(connect-slurm-to-cos)=
# How to connect Slurm to COS

This how-to guide shows you how to connect Slurm to the
Canonical Observability Stack (COS) to monitor and observe a deployed Slurm cluster.

## Prerequisites

To successfully connect Slurm to COS, you must have:

- [A deployed COS cloud](https://charmhub.io/topics/canonical-observability-stack/tutorials)
  with [ingress enabled](https://charmhub.io/topics/canonical-observability-stack/explanation/ingress).
- {ref}`A deployed Slurm cluster. <deploy-slurm>`
- The [Juju CLI client](https://juju.is/docs/juju/install-and-manage-the-client) installed on your machine.

Once you have verified that you have met the prerequisites above, proceed to the instructions below.

## Deploy Grafana Agent

First, in the model holding your Slurm deployment, use `juju deploy`{l=shell} to
deploy Grafana Agent:

:::{code-block} shell
juju deploy grafana-agent
:::

## Connect Slurm to Grafana Agent

After deploying Grafana Agent to the same model as your Slurm deployment,
connect the agent to the Slurm controller, use `juju integrate`{l=shell} to integrate
the Slurm controller and Grafana Agent together:

:::{code-block} shell
juju integrate slurmctld:cos-agent grafana-agent:cos-agent
:::

## Connect Grafana Agent to COS

With Grafana Agent deployed to the same machine as the Slurm controller, use `juju consume`{l=shell}
to consume the cross-model offers provided by COS in the model holding your Slurm deployment:

:::{code-block} shell
juju consume microk8s:admin/cos.prometheus-receive-remote-write
juju consume microk8s:admin/cos.loki-logging
juju consume microk8s:admin/cos.grafana-dashboards
:::

:::{important}
Ensure that your COS cloud has ingress enabled before integrating Grafana Agent with the
`grafana-dashboards`, `loki-logging`, and `prometheus-receive-remote-write` endpoints . If your
COS cloud does not have ingress enabled, Grafana Agent will be unable to forward
collected logs and metrics from Slurm.

See [Charmed ingress on k8s with Traefik and Traefik-Route](https://charmhub.io/topics/canonical-observability-stack/explanation/ingress)
for additional details.
:::

Now use `juju integrate`{l=shell} to integrate Grafana Agent to COS:

:::{code-block} shell
juju integrate grafana-agent prometheus-receive-remote-write
juju integrate grafana-agent loki-logging
juju integrate grafana-agent grafana-dashboards
:::
