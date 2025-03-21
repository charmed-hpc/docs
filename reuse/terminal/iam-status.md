After a few minutes, your GLAuth deployment will become active. The output
of `juju status`{l=shell} will be similar to the following:

:::{terminal}
:input: juju status
:scroll:
Model  Controller              Cloud/Region             Version  SLA          Timestamp
iam    charmed-hpc-controller  charmed-hpc-k8s/default  3.6.4    unsupported  14:24:50-04:00

App                       Version  Status  Scale  Charm                     Channel        Rev  Address         Exposed  Message
glauth-k8s                         active      1  glauth-k8s                latest/edge     52  10.152.183.159  no
postgresql-k8s            14.15    active      1  postgresql-k8s            14/stable      495  10.152.183.236  no
self-signed-certificates           active      1  self-signed-certificates  latest/stable  264  10.152.183.57   no
traefik-k8s               2.11.0   active      1  traefik-k8s               latest/stable  232  10.152.183.122  no       Serving at 10.175.90.230

Unit                         Workload  Agent  Address     Ports  Message
glauth-k8s/0*                active    idle   10.1.0.165
postgresql-k8s/0*            active    idle   10.1.0.45          Primary
self-signed-certificates/0*  active    idle   10.1.0.128
traefik-k8s/0*               active    idle   10.1.0.73          Serving at 10.175.90.230
:::

With GLAuth successfully deployed, you'll now need to deploy SSSD in your `slurm`
model to enroll your cluster's machines with GLAuth.
