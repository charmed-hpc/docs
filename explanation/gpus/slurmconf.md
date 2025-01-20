(slurmconf)=
# Slurm enlistment

To allow cluster users to submit jobs requesting GPUs, detected GPUs are automatically added to the [Generic RESource (GRES) Slurm configuration](https://slurm.schedmd.com/gres.html). GRES is a feature in Slurm which enables scheduling of arbitrary generic resources, including GPUs.

## Device details

GPU details are gathered by [`pynvml`](https://pypi.org/project/nvidia-ml-py/), the official Python bindings for the Nvidia management library, which enables GPU counts, associated device files and model names to be queried from the drivers. For compatibility with Slurm configuration files, retrieved model names are converted to lowercase and white space is replaced with underscores. “Tesla T4” becomes `tesla_t4`, for example.

## Slurm configuration

Each GPU-equipped node is added to the `gres.conf` configuration file following the format defined in the [Slurm `gres.conf` documentation](https://slurm.schedmd.com/gres.conf.html). A single `gres.conf` is shared by all compute nodes in the cluster, using the optional `NodeName` specification to define GPU resources per node. Each line in `gres.conf` consists of the following parameters:

| Parameter  | Value                                                      |
| ---------- | ---------------------------------------------------------- |
| `NodeName` | Node the `gres.conf` line applies to.                      |
| `Name`     | Name of the generic resource. Always `gpu` here.           |
| `Type`     | GPU model name.                                            |
| `File`     | Path of the device file(s) associated with this GPU model. |

In `slurm.conf`, the configuration for GPU-equipped nodes has a comma-separated list in its `Gres=` element, giving the name, type, and count for each GPU on the node.

For example, a Microsoft Azure `Standard_NC24ads_A100_v4` node, equipped with a NVIDIA A100 PCIe GPU, is given a node configuration in `slurm.conf` of:

```
NodeName=juju-e33208-1 CPUs=24 Boards=1 SocketsPerBoard=1 CoresPerSocket=24 ThreadsPerCore=1 RealMemory=221446 Gres=gpu:nvidia_a100_80gb_pcie:1 MemSpecLimit=1024
```

and corresponding `gres.conf` line:

```
NodeName=juju-e33208-1 Name=gpu Type=nvidia_a100_80gb_pcie File=/dev/nvidia0
```

## Libraries used

- [`pynvml / nvidia-ml-py`](https://pypi.org/project/nvidia-ml-py/), from PyPI.

