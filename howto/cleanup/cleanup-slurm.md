---
relatedlinks: "[`juju&#32;destroy-model`&#32;documentation](https://documentation.ubuntu.com/juju/3.6/reference/juju-cli/list-of-juju-cli-commands/destroy-model/)"
---


(howto-cleanup-slurm)=
# How to clean up Slurm

:::{admonition} Removing all Charmed HPC resources?
:class: note

If you are planning to tear down the entire Charmed HPC environment - all models, storage and
controllers - you can jump to {ref}`howto-cleanup-cloud-resources` instead to remove all resources,
including Slurm, in a single step.
:::

This how-to guide shows you how to remove a [previously deployed Slurm workload manager](#howto-setup-deploy-slurm)
in a Charmed HPC cluster.

## Destroy Slurm

:::{admonition} Data loss warning
:class: warning

Destroying your Slurm deployment may result in **permanent data loss**. Ensure all data you wish to
preserve has been migrated to a safe location before proceeding, or consider using the flag
`--release-storage` with `juju destroy-model`{l=shell} to release the deployment's storage
rather than destroy it.
:::

Use `juju destroy-model`{l=shell} to destroy your Slurm deployment. You will need to provide
the name of the model your Slurm deployment is located in. For example, to destroy to Slurm
deployment located in the `slurm` model, run:

:::{code-block} shell
juju destroy-model --no-prompt --destroy-storage slurm
:::

:::{include} /reuse/common/tip-listing-juju-models.txt
:::

## Forcibly destroy a stuck Slurm deployment

Your model may become stuck if any of Slurm's service are in an error state during
the model cleanup process. You can determine if your model is stuck by seeing repeated
`Waiting for model to be removed` messages printed to the terminal.

If your Slurm model is stuck, add the `--force` flag to `juju destroy-model`{l=shell} to
destroy your Slurm deployment and ignore errors:

:::{code-block} shell
juju destroy-model --no-prompt --destroy-storage --force slurm
:::

See the [Juju `destroy-model` documentation](https://documentation.ubuntu.com/juju/3.6/reference/juju-cli/list-of-juju-cli-commands/destroy-model/)
for the implications of using the `--force` flag and details of further
available options.

## Next Steps

Now that you have destroyed your Slurm deployment, you can also clean up your cloud resources:

- {ref}`howto-cleanup-cloud-resources`

You can also revisit {ref}`howto-setup-deploy-slurm` if you want to create a new Slurm deployment.
