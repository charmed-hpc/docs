---
relatedlinks: "[Slurm&#32;Workload&#32;Manager&#32;-&#32;gres.conf](https://slurm.schedmd.com/gres.conf.html)"
---

(explanation-gpus)=
# GPUs

A Graphics Processing Unit (GPU) is a specialized hardware resource that was originally designed to accelerate computer graphics calculations but has expanded use in general purpose computing across a number of fields. GPU-enabled workloads are supported on a Charmed HPC cluster with the necessary driver and workload manager configuration automatically handled by the charms.


(driver)=
## GPU driver installation and management

### Auto-install

Charmed HPC installs GPU drivers when the `slurmd` charm is deployed on a compute node equipped with a supported NVIDIA GPU. Driver detection is performed via the API for [`ubuntu-drivers-common`](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/#the-recommended-way-ubuntu-drivers-tool), a package which examines node hardware, determines appropriate third-party drivers and recommends a set of driver packages that are installed from the Ubuntu repositories.

### Libraries used

- [`ubuntu-drivers-common`](https://github.com/canonical/ubuntu-drivers-common), from GitHub.


(slurmconf)=
# Slurm enlistment

To allow cluster users to submit jobs requesting GPUs, detected GPUs are automatically added to the [Generic RESource (GRES) Slurm configuration](https://slurm.schedmd.com/gres.html). GRES is a feature in Slurm which enables scheduling of arbitrary generic resources, including GPUs.

## Device details

GPU details are gathered by [`pynvml`](https://pypi.org/project/nvidia-ml-py/), the official Python bindings for the NVIDIA management library, which enables GPU counts, associated device files and model names to be queried from the drivers. For compatibility with Slurm configuration files, retrieved model names are converted to lowercase and white space is replaced with underscores. “Tesla T4” becomes `tesla_t4`, for example.

## Slurm configuration

Each GPU-equipped node is added to the _gres.conf_ configuration file following the format defined in the [Slurm _gres.conf_ documentation](https://slurm.schedmd.com/gres.conf.html). A single _gres.conf_ is shared by all compute nodes in the cluster, using the optional `NodeName` specification to define GPU resources per node. Each line in _gres.conf_ uses the following parameters to define a GPU resource:

| Parameter  | Value                                                      |
| ---------- | ---------------------------------------------------------- |
| `NodeName` | Node the _gres.conf_ line applies to.                      |
| `Name`     | Name of the generic resource. Always `gpu` here.           |
| `Type`     | GPU model name.                                            |
| `File`     | Path of the device file(s) associated with this GPU model. |

In _slurm.conf_, if a node is GPU-equipped, its configuration line includes an additional `Gres=`, element, containing a comma-separated list of GPU configurations. If a node is not GPU-equipped, its configuration line does not contain `Gres=`. The format for each configuration is: `<name>:<type>:<count>`, as seen in the example below.

For example, a Microsoft Azure `Standard_NC24ads_A100_v4` node, equipped with a NVIDIA A100 PCIe GPU, is given a node configuration in _slurm.conf_ of:

```
NodeName=juju-e33208-1 CPUs=24 Boards=1 SocketsPerBoard=1 CoresPerSocket=24 ThreadsPerCore=1 RealMemory=221446 Gres=gpu:nvidia_a100_80gb_pcie:1 MemSpecLimit=1024
```

and corresponding _gres.conf_ line:

```
NodeName=juju-e33208-1 Name=gpu Type=nvidia_a100_80gb_pcie File=/dev/nvidia0
```

## Libraries used

- [`pynvml / nvidia-ml-py`](https://pypi.org/project/nvidia-ml-py/), from PyPI.

