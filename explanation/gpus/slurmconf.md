(slurmconf)=
# Slurm enlistment

To allow cluster users to submit jobs requesting GPUs, detected GPUs are automatically added to the [Generic RESource (GRES) Slurm configuration](https://slurm.schedmd.com/gres.html). This is a feature in Slurm which enables scheduling of arbitrary generic resources, including GPUs.

## Device details

GPU details are gathered by [`pynvml`](https://pypi.org/project/nvidia-ml-py/), the official Python bindings for the Nvidia management library, which enables GPU counts, associated device files and model names to be queried from the drivers. For compatibility with Slurm configuration files, retrieved model names are converted to lowercase and white space is replaced with underscores. “Tesla T4” becomes `tesla_t4`, for example.

## Slurm configuration

Each GPU-equipped node is added to the `gres.conf` configuration file as its own `NodeName` entry, following the format defined in the [Slurm `gres.conf` documentation](https://slurm.schedmd.com/gres.conf.html). Individual `NodeName` entries are used over an entry per GRES resource to provide greater support for heterogeneous environments, such as a cluster where the same model of GPU is not consistently the same device file across compute nodes.

In `slurm.conf`, the configuration for GPU-equipped nodes has a comma-separated list in its `Gres=` element, giving the name, type and count for each GPU on the node.

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

