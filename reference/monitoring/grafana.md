---
relatedlinks: "[Grafana&#32;dashboards&#32;documentation](https://grafana.com/docs/grafana/latest/dashboards/)"
---

(reference-monitoring-grafana)=
# Grafana dashboards

This is an overview of all the charms used in Charmed HPC that provide dashboards for
{term}`Grafana`, which acts as a web interface to visualize data from aggregators such
as {term}`Prometheus` or {term}`Loki`.

See {ref}`howto-manage-integrate-with-cos` for more information.

:::{admonition} Panel query
:class: note

Any panel can be inspected using the [panel inspect view](https://grafana.com/docs/grafana/latest/panels-visualizations/panel-inspector/)
to see the exact query used to provide the panel with data.
:::

## Slurmctld

The dashboards from the {term}`slurmctld` charm provide a display of information from the
entire cluster, each partition, and each charm.

### Cluster Overview

The "Cluster Overview" dashboard provides a display of cluster-level metrics such as:

- Total resource utilization
- Job status distribution
- Node state distribution
- Scheduler metrics

![Grafana Cluster Overview dashboard showing total resource utilization, job state distribution, node state distribution, and scheduler metrics for the Charmed HPC cluster](/reuse/reference/monitoring/cluster-overview.png)

### Partition Overview

The "Partition Overview" dashboard provides a display of partition-level metrics such as:

- Total nodes and jobs in the partition
- Total resource utilization for the partition
- Job status distributing for jobs in the partition
- Node state distribution for all nodes in the partition

![Grafana Partition Overview dashboard showing total nodes and jobs, resource utilization, job status distribution, and node state distribution for a specific partition](/reuse/reference/monitoring/partition-overview.png)

### Node Overview

The "Node Overview" dashboard provides a display of node-level metrics such as:

- Available resources that are allocatable for jobs
- Total resource utilization on the node

![Grafana Node Overview dashboard showing node state, resource utilization, running jobs, and hardware configuration for a specific compute node](/reuse/reference/monitoring/node-overview.png)

## MySQL

The dashboard from the `mysql` charm displays metrics for the storage database of Slurmdbd:

- Uptime
- Queries per second
- Current cache size
- Maximum number of concurrent connections
- Thread resource usage
- Network traffic statistics

![MySQL dashboard](/reuse/reference/monitoring/mysql_grafana.png)

## Traefik K8s

The dashboard from the `traefik-k8s` charm displays metrics about the reverse proxy used when communicating
between the compute plane cluster and the monitoring/identity k8s clusters. This includes:

- Uptime
- Response times
- HTTP response code statistics
- Open connection statistics.
- Raw logs for every proxied endpoint

![Traefik dashboard](/reuse/reference/monitoring/traefik_grafana.png)
