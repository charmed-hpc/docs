(reference-benchmarks)=
# Benchmark metrics and results

Reference values for the [Charmed HPC Benchmarks](https://github.com/charmed-hpc/charmed-hpc-benchmarks/) running on Microsoft Azure are provided on this page.

## Method

* Juju 3.6.3, ReFrame 4.7.4, Ubuntu 24.04, gcc 13.3.0, CUDA toolkit 12.0.140.
* Cluster deployed on Microsoft Azure:
  * One `Standard_NC4as_T4_v3` instance, equipped with an NVIDIA Tesla T4, chosen for GPU benchmarking.
  * Two `Standard_HB120rs_v3` instances, equipped with 200 Gb/s HDR InfiniBand, chosen for RDMA benchmarking.
  * All other instances are `Standard_D2as_v6`, the default size for Juju 3.6.3.
* Results obtained with the following charm versions:

:::{csv-table}
:header: >
: application, vm size, charm, channel, revision

`login`, 1x `Standard_D2as_v6`, sackd, edge, 13
`slurmctld`, 1x `Standard_D2as_v6`, slurmctld, edge, 95
`slurmdbd`, 1x `Standard_D2as_v6`, slurmdbd, edge, 87
`mysql`, 1x `Standard_D2as_v6`, mysql, 8.0/stable, 313
`nc4as-t4-v3`, 1x `Standard_NC4as_T4_v3`, slurmd, edge, 116
`hb120rs-v3`, 2x `Standard_HB120rs_v3`, slurmd, edge, 116
`nfs-share-client`, N/A - subordinate charm, filesystem-client, edge, 15
`nfs-share-server`, 1x `Standard_D2as_v6`, nfs-server-proxy, edge, 21
:::


## Metrics

### Tesla T4 GPU

GPU single and double precision floating point performance is measured by the [gpu_burn](http://wili.cc/blog/gpu-burn.html) stress test, with [code modifications by the ReFrame developers](https://github.com/reframe-hpc/reframe/tree/v4.7.4/hpctestlib/microbenchmarks/gpu/src/gpu_burn), built using the CUDA toolkit.

### InfiniBand interconnect

InfiniBand latency and bandwidth are measured by the [OSU Micro-Benchmarks](https://mvapich.cse.ohio-state.edu/benchmarks/) for MPI and the [Intel MPI Benchmarks (IMB)](https://github.com/intel/mpi-benchmarks). All benchmark runs are performed on two cluster compute nodes, one MPI process per node.

Point-to-point performance is measured with the OSU `osu_bw` and `osu_latency` benchmarks, as well as the IMB MPI-1 `PingPong` benchmark.

Collective performance is measured with the OSU `osu_alltoall` and `osu_allreduce` benchmarks, as well as the IMB MPI-1 `AllReduce` benchmark.

## Results

Results are the best performance achieved by the benchmarking suite across all tests.

:::{csv-table}
:header: >
: metric, vm size, result, unit, note

Tesla T4 single precision, 1x `Standard_NC4as_T4_v3`, 4454, Gflops/s,
Tesla T4 double precision, 1x `Standard_NC4as_T4_v3`, 252, Gflops/s,
InfiniBand latency, 2x `Standard_HB120rs_v3`, 1.59, us, 1 byte transfer size
InfiniBand bandwidth, 2x `Standard_HB120rs_v3`, 196.06, Gb/s, 4 MiB transfer size
:::
