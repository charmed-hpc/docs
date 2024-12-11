(access-grafana)=
# How to access the Grafana dashboard

This how-to guide shows you how to access the Grafana dashboard
to explore and analyze metrics collected from your Charmed HPC cluster.

## Prerequisites

Before accessing the Grafana dashboard, you should have:

- {ref}`Connected your cluster's workload manager to COS <connect-workload-manager-to-cos>`.

## Get the Grafana admin password and URL

To get the admin password and URL for the Grafana dashboard, run the
`get-admin-password` action on the Grafana application leader:

```shell
juju run grafana/leader -m cos get-admin-password --wait 1m
```

## Log into Grafana

Copy the returned URL into the address bar of your preferred web browser to
open the Grafana login page. Enter __admin__ as the username and the returned
admin password as the password.

```{important}
The `get-admin-password` action returns the initial admin password that is
generated when COS is first deployed. The action will return a notice if the
initial admin password has been changed by the COS administrator. If this is the
case, you will need to get either a Grafana account or the admin password from
your COS administrator.
```
