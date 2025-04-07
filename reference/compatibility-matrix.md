(reference-compatibility-matrix)=
# Compatibility Matrix

The tables below provide an overview of cloud instance types that have been tested for compatibility with Charmed HPC revisions. Inclusion in a table indicates that the corresponding VM type has been tested; however, exclusion from the table simply indicates that the instance has not been tested thoroughly and may be compatible or incompatible with Charmed HPC. 

The compatibility key:

* <span style="color:green">&#x2714; Compatible</span>: Fully compatible with all Charmed HPC features. No known issues.
* <span style="color:orange">&#x25B3; Partial</span>: May be compatible with a subset of Charmed HPC features or may have issues that require work-arounds.
* <span style="color:red">&#x2718; Incompatible</span>: Has issues that prevent all use-cases.

## Microsoft Azure

To decide on suitable VMs, it may be useful to refer to [Sizes for virtual machines in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview). A typical Charmed HPC deployment will use a mix of high-performance and GPU-accelerated compute VMs for cluster compute nodes, and general purpose VMs for other node types.

### Charm: `sackd`

**Revision:** 13

:::{csv-table}
:header: >
: instance type, series, compatibility, notes
:widths: 9, 5, 6, 9

Standard_D2as_v6, [Dasv6](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dasv6-series), <span style="color:green">&#x2714; Compatible</span>, ""
:::

### Charm: `slurmctld`

**Revision:** 95

:::{csv-table}
:header: >
: instance type, series, compatibility, notes
:widths: 9, 5, 6, 9

Standard_D2as_v6, [Dasv6](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dasv6-series), <span style="color:green">&#x2714; Compatible</span>, ""
:::

### Charm: `slurmd`

**Revision:** 116

:::{csv-table}
:header: >
: instance type, series, compatibility, notes
:widths: 9, 5, 6, 9

Standard_HB120rs_v3, [HBv3](https://learn.microsoft.com/en-us/azure/virtual-machines/hbv3-series-overview), <span style="color:green">&#x2714; Compatible</span>, ""
Standard_HB176rs_v4, [HBv4](https://learn.microsoft.com/en-us/azure/virtual-machines/hbv4-series-overview), <span style="color:green">&#x2714; Compatible</span>, ""
Standard_NC24ads_A100_v4, [NC_A100_v4](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/nca100v4-series), <span style="color:green">&#x2714; Compatible</span>, ""
Standard_NC4as_T4_v3, [NCasT4_v3](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/ncast4v3-series), <span style="color:green">&#x2714; Compatible</span>, ""
Standard_NV6ads_A10_v5, [NVadsA10_v5](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/nvadsa10v5-series), <span style="color:red">&#x2718; Incompatible</span>, "GPU driver failures. See [#82](https://github.com/charmed-hpc/slurm-charms/issues/82)"
:::

### Charm: `slurmdbd`

**Revision:** 87

:::{csv-table}
:header: >
: instance type, series, compatibility, notes
:widths: 9, 5, 6, 9

Standard_D2as_v6, [Dasv6](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dasv6-series), <span style="color:green">&#x2714; Compatible</span>, ""
:::

### Charm: `slurmrestd`

**Revision:** 89

:::{csv-table}
:header: >
: instance type, series, compatibility, notes
:widths: 9, 5, 6, 9

Standard_D2as_v6, [Dasv6](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dasv6-series), <span style="color:green">&#x2714; Compatible</span>, ""
:::
