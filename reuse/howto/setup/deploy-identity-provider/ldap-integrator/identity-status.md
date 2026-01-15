Your ldap-integrator application will become active within a few minutes. The output
of `juju status`{l=shell} will be similar to following:

:::{terminal}
:scroll:

juju status

Model     Controller              Cloud/Region         Version  SLA          Timestamp
identity  charmed-hpc-controller  charmed-hpc/default  3.6.12   unsupported  17:02:01-05:00

App              Version  Status  Scale  Charm            Channel      Rev  Exposed  Message
ldap-integrator           active      1  ldap-integrator  latest/edge   35  no

Unit                Workload  Agent  Machine  Public address  Ports  Message
ldap-integrator/0*  active    idle   0        10.214.237.205

Machine  State    Address         Inst id        Base          AZ   Message
0        started  10.214.237.205  juju-dade42-0  ubuntu@22.04       Running
:::

You now need to deploy SSSD in your `slurm` model to enroll your cluster's
machines with the external LDAP server.
