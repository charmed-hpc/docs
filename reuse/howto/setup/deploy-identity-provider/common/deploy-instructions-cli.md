First, use `juju deploy`{l=shell} to deploy SSSD in your `slurm` model:

:::{code-block} shell
juju deploy sssd --base "ubuntu@24.04" --channel "edge"
:::

Now use `juju integrate`{l=shell} to integrate SSSD with the Slurm services
`sackd` and `slurmd`:

:::{code-block} shell
juju integrate sssd sackd
juju integrate sssd slurmd
:::

:::{include} /reuse/howto/setup/deploy-identity-provider/common/sssd-no-ldap-status.md
:::
