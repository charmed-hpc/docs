(reference-interconnects)=
# Public cloud high-speed interconnects

:::{csv-table}
:header: >
: cloud, interconnect, instance availability, subnet management, deployment notes

[Amazon Web Services](https://aws.amazon.com/), [Elastic Fabric Adapter (EFA)](https://aws.amazon.com/hpc/efa/), [Supported instance types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html#efa-instance-types), Provided by cloud, **Not supported** <!-- [Manual setup documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start.html) -->
[Microsoft Azure](https://portal.azure.com), [InfiniBand](https://learn.microsoft.com/en-us/azure/virtual-machines/setup-infiniband), [RDMA-capable instances](https://learn.microsoft.com/en-us/azure/virtual-machines/setup-infiniband#rdma-capable-instances), Provided by cloud, VMs in the same [availability set](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview) have the same InfiniBand PKEY.<br><br>All units in a Juju application are deployed in the same availability set automatically.
:::
