After a few minutes, your SSSD deployment will reach waiting status.
The output of `juju status`{l=shell} will be similar to the following:

:::{terminal}
:input: juju status
:scroll:
Model  Controller              Cloud/Region         Version  SLA          Timestamp
slurm  charmed-hpc-controller  charmed-hpc/default  3.6.4    unsupported  16:17:13-04:00

App         Version          Status   Scale  Charm       Channel      Rev  Exposed  Message
mysql       8.0.39-0ubun...  active       1  mysql       8.0/stable   313  no
sackd       23.11.4-1.2u...  active       1  sackd       latest/edge   13  no
slurmctld   23.11.4-1.2u...  active       1  slurmctld   latest/edge   95  no
slurmd      23.11.4-1.2u...  active       1  slurmd      latest/edge  116  no
slurmdbd    23.11.4-1.2u...  active       1  slurmdbd    latest/edge   87  no
slurmrestd  23.11.4-1.2u...  active       1  slurmrestd  latest/edge   89  no
sssd        2.9.4-1.1ubu...  waiting      2  sssd        latest/edge    6  no       Waiting for integrations: [`ldap`]

Unit           Workload  Agent  Machine  Public address  Ports           Message
mysql/0*       active    idle   3        10.175.90.111   3306,33060/tcp  Primary
sackd/0*       active    idle   0        10.175.90.64
  sssd/1       waiting   idle            10.175.90.64                    Waiting for integrations: [`ldap`]
slurmctld/0*   active    idle   4        10.175.90.100
slurmd/0*      active    idle   5        10.175.90.107
  sssd/0*      waiting   idle            10.175.90.107                   Waiting for integrations: [`ldap`]
slurmdbd/0*    active    idle   2        10.175.90.105
slurmrestd/0*  active    idle   1        10.175.90.215

Machine  State    Address        Inst id        Base          AZ  Message
0        started  10.175.90.64   juju-0f356d-0  ubuntu@24.04      Running
1        started  10.175.90.215  juju-0f356d-1  ubuntu@24.04      Running
2        started  10.175.90.105  juju-0f356d-2  ubuntu@24.04      Running
3        started  10.175.90.111  juju-0f356d-3  ubuntu@22.04      Running
4        started  10.175.90.100  juju-0f356d-4  ubuntu@24.04      Running
5        started  10.175.90.107  juju-0f356d-5  ubuntu@24.04      Running
:::

For SSSD to reach active status, you'll now need to integrate SSSD with
GLAuth in your `iam` model so that SSSD can enroll your machines with GLAuth.
