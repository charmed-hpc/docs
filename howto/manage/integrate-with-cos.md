---
relatedlinks: "[Get&#32;started&#32;with&#32;COS](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s), [COS&#32;best&#32;practices](https://charmhub.io/topics/canonical-observability-stack/reference/best-practices)"
---

(howto-manage-integrate-with-cos)=
# Integrate with Canonical Observability Stack

This how-to guide provides instructions for connecting Charmed HPC to the
Canonical Observability Stack (COS). This integration enables you to monitor your
deployed Charmed HPC cluster by forwarding collected logs and metrics from
your cluster's services to COS for interactive analysis.

:::{hint}
If you're unfamiliar with operating COS, see the [COS tutorials](https://charmhub.io/topics/canonical-observability-stack/tutorials)
for a high-level introduction to the Canonical Observability Stack.
:::

## Prerequisites

To integrate Charmed HPC with COS, you will need:

* An [isolated](https://charmhub.io/topics/canonical-observability-stack/reference/best-practices#deploy-in-isolation) [COS deployment](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s) with [ingress](https://charmhub.io/topics/canonical-observability-stack/explanation/ingress) enabled
* An active [Slurm deployment](#howto-setup-deploy-slurm) in your [`charmed-hpc` machine cloud](#howto-initialize-machine-cloud)
* The [Juju CLI client](https://documentation.ubuntu.com/juju/latest/user/howto/manage-juju/) installed on your machine
* The [`jq` CLI command](https://jqlang.org/download/) installed on your machine

:::{important}
Your COS deployment __must__ have ingress enabled. If your COS deployment does not have
ingress enabled, Charmed HPC will be unable to forward collected logs and metrics as COS
will be unreachable over the network.
:::

:::{note}
The instructions below assume that Charmed HPC and COS have their own, individual controllers,
and that they are connected together with cross-model integration endpoints.

The instructions below also assume that the name of the COS controller is `cos-controller`, and
that the model holding your COS deployment is named `cos`. If the name of your COS controller is
not `cos-controller`, or the name of your model is not `cos`, substitute `cos-controller`
and `cos` with the names of your COS controller and model in the commands below.
:::

## Connect to COS

Follow the instructions below for how to integrate COS with Charmed HPC.

### Deploy Grafana Agent

First, within your `charmed-hpc` cloud, use `juju deploy`{l=shell} to deploy Grafana Agent
on your cluster:

:::{code-block} shell
juju deploy grafana-agent --model charmed-hpc-controller:slurm \
  --base "ubuntu@24.04"
:::

### Connect Charmed HPC to Grafana Agent

Still within your `charmed-hpc` cloud, use `juju integrate`{l=shell} to connect Grafana
Agent to your cluster's applications:

:::{code-block}
juju integrate --model charmed-hpc-controller:slurm grafana-agent slurmctld
:::

After integrating Grafana Agent with your cluster's applications, Grafana Agent will
install itself on each unit of the application to collect logs and metrics.

(howto-manage-integrate-with-cos-get-cos-urls)=
### Get COS URLs

Before you connect Grafana Agent to COS, you'll want to ensure that your `charmed-hpc` cloud
can successfully contact your COS deployment over the network. To perform this connectivity check,
first grab the URLs of the COS services from [`Catalogue`](https://charmhub.io/catalogue-k8s) by running the following command:

:::{code-block} shell
juju show-unit --model cos-controller:cos catalogue/0 --format json | \
  jq '.[]."relation-info".[]."application-data".url | select (. != null)'
:::

The piped output of the `juju show-unit`{l=shell} command should be similar to the following:

:::{terminal}
:copy:
:input: juju show-unit --model cos-controller:cos catalogue/0 --format json | jq '.[]."relation-info".[]."application-data".url | select (. != null)'

"http://10.190.89.230/cos-grafana"
"http://10.190.89.230/cos-prometheus-0"
"http://10.190.89.230/cos-alertmanager"
:::

Save these URLs as they will be useful in the
{ref}`howto-manage-integrate-with-cos-access-monitoring-resources` section.

### Check connectivity

To verify that your `charmed-hpc` cloud can connect to your COS deployment, try to access
Prometheus by running the following `curl` command with `juju exec`{l=shell}:

:::{code-block} shell
juju exec --unit grafana-agent/0 \
  "curl -s http://10.190.89.230/cos-prometheus-0/api/v1/status/runtimeinfo"
:::

If the output of `juju exec`{l=shell} looks similar to the success message below, this
means that your `charmed-hpc` cloud can successfully contact your COS deployment:

:::{terminal}
:copy:
:input: juju exec --unit grafana-agent/0 -- curl -s http://10.190.89.230/cos-prometheus-0/api/v1/status/runtimeinfo

{"status":"success","data":{"startTime":"2025-02-06T19:09:05.141616388Z","CWD":"/","reloadConfigSuccess":true,"lastConfigTime":"2025-02-06T19:10:36Z","corruptionCount":0,"goroutineCount":56,"GOMAXPROCS":8,"GOMEMLIMIT":9223372036854775807,"GOGC":"","GODEBUG":"","storageRetention":"15d or 819MiB204KiB819B"}}
:::

### Make offers from COS

Now that you have verified that your `charmed-hpc` cloud can connect to your COS deployment,
create offers in your COS deployment using `juju offer`{l=shell}. You can use `juju switch`{l=shell}
to switch to your `cos` model:

:::{code-block} shell
juju switch cos-controller:cos
juju offer cos.grafana:grafana-dashboard grafana-dashboards
juju offer cos.loki:logging loki-logging
juju offer cos.prometheus:receive-remote-write prometheus-receive-remote-write
:::

### Consume offers in Charmed HPC

After making the offers in your `cos` model, use `juju consume` to consume the offers
in your `slurm` model on your `charmed-hpc` cloud. You can use `juju switch`{l=shell}
to switch to your `slurm` model:

:::{code-block} shell
juju switch charmed-hpc-controller:slurm
juju consume cos-controller:cos.prometheus-receive-remote-write
juju consume cos-controller:cos.grafana-dashboards
juju consume cos-controller:cos.loki-logging
:::

### Connect Grafana Agent to COS endpoints

Now use `juju integrate`{l=shell} to connect Grafana Agent to the COS endpoints:

:::{code-block} shell
juju switch charmed-hpc-controller:slurm
juju integrate grafana-agent prometheus-receive-remote-write
juju integrate grafana-agent loki-logging
juju integrate grafana-agent grafana-dashboards
:::

With Grafana Agent connected to COS, you can now use the URLs from the
{ref}`howto-manage-integrate-with-cos-get-cos-urls` section to access monitoring resources
such as metrics, logs, and alerts collected from your Charmed HPC cluster. See the
{ref}`howto-manage-integrate-with-cos-access-monitoring-resources` section below for how to
access these monitoring resources through your browser.

(howto-manage-integrate-with-cos-access-monitoring-resources)=
## Access monitoring resources

Follow the instructions below for how to view alerts, logs, and metrics collected from
your Charmed HPC cluster after you have integrated your cluster with COS.

### Access Grafana dashboards

First, in your terminal, retrieve the Grafana admin password with the `get-admin-password` action:

:::{code-block} shell
juju run grafana/leader --model cos-controller:cos \
  --wait 1m \
  get-admin-password
:::

:::{important}
The `get-admin-password` action returns the initial admin password that is
generated when COS is first deployed. The action will return a notice if the
initial admin password has been changed by the COS administrator. If this is the
case, you will need to get either a Grafana account or the admin password from
your COS administrator.
:::

Next, open your browser and navigate to the Grafana dashboard URL you received after running
the piped `juju show-unit`{l=shell} command in the
{ref}`howto-manage-integrate-with-cos-get-cos-urls` section.

Log in as the user `admin` using the password returned by the `get-admin-password` action.
You can see the available dashboards by opening the sidebar menu and clicking on `Dashboards`.

## Next steps

You can now use COS to monitor your Charmed HPC cluster. Explore the Grafana web interface
to see what dashboards you can create using the metrics collected from your
Charmed HPC cluster.
