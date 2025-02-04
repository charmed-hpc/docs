(explanation-interconnects)=
# High-speed interconnects

A high-speed interconnect is a networking technology which enables performant communication and data transfer between nodes in a cluster. Communication is both high-bandwidth (large throughput) and low-latency (minimal delay). Performant communication is particularly beneficial for applications which can span multiple compute nodes, such as applications that employ the Message Passing Interface (MPI) standard for parallel computing.

This performance is achieved through Remote Direct Memory Access (RDMA): a mechanism that enables a networked (remote) computer to directly access the memory of another computer, independently of either computer's CPU and operating system. NVIDIA InfiniBand is a common implementation of RDMA.

- {ref}`explanation-rdma-driver`

```{toctree}
:titlesonly:
:maxdepth: 1
:hidden:

Drivers <driver>
```
