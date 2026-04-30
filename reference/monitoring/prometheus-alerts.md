(reference-monitoring-prometheus-alerts)=
# Prometheus alerts

This page lists the Prometheus alert rules provided by Charmed HPC charms. These alerts
fire when specific conditions are met in your cluster and can be viewed in the Prometheus
or {term}`Grafana` web interface.

See {ref}`howto-manage-integrate-with-cos` for instructions on integrating with COS.

```{note}
The tables below provide the following information:

- **Alert**: the alert name as shown in the Prometheus dashboard.
- **Description**: a summary of when the alert is triggered.
- **Severity**: the alert severity (`warning` or `critical`).
```

## Sackd

:::{list-table}
:header-rows: 1

* - Alert
  - Description
  - Severity
* - `SlurmLoginNodeSackdServiceIsInactive`
  - The `sackd` service has been inactive for more than 5 minutes on a login node.
  - warning
* - `SlurmLoginNodeSackdServiceHasFailed`
  - The `sackd` service has failed on a login node.
  - critical
:::

## Slurmctld

:::{list-table}
:header-rows: 1

* - Alert
  - Description
  - Severity
* - `SlurmJobsHighFailureRate`
  - More than 10 jobs have failed in the last 15 minutes.
  - warning
* - `SlurmJobsPendingForTooLong`
  - More than 10 jobs have been pending for longer than 1 hour.
  - warning
* - `SlurmPartitionNearingFull`
  - A partition has less than 10% of its nodes idle.
  - warning
* - `SlurmPartitionMaxMemoryLimit`
  - A partition has allocated more than 90% of its available memory.
  - warning
* - `SlurmPartitionMaxCPULimit`
  - A partition has allocated more than 90% of its available CPU capacity.
  - warning
* - `SlurmTooManyFailedDbdMessages`
  - The Slurm controller's pending message queue to the Slurm database exceeded 5000 in the past minute.
  - critical
* - `SlurmNodesDrainingTooLong`
  - One or more compute nodes have been draining for more than 3 hours.
  - warning
* - `SlurmNodesFailing`
  - One or more compute nodes have been reporting as `FAIL` for more than 5 minutes.
  - critical
* - `SlurmNodesNotResponding`
  - One or more compute nodes are not responding to the Slurm controller for more than 5 minutes.
  - critical
* - `SlurmNodesInUnknownState`
  - One or more compute nodes have been reporting as `UNKNOWN` for more than 5 minutes.
  - critical
:::

## Slurmd

:::{list-table}
:header-rows: 1

* - Alert
  - Description
  - Severity
* - `SlurmComputeNodeSlurmdServiceIsInactive`
  - The `slurmd` service has been inactive for more than 5 minutes on a compute node.
  - warning
* - `SlurmComputeNodeSlurmdServiceHasFailed`
  - The `slurmd` service has failed on a compute node.
  - critical
* - `SlurmComputeNodeNvidiaGPUIsOverheating`
  - A GPU has exceeded 90°C on a compute node.
  - warning
* - `SlurmComputeNodeGPUXIDErrorsDetected`
  - XID errors are being reported on a GPU on a compute node.
  - warning
:::
