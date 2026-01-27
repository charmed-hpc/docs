module "filesystem-client" {
  source     = "git::https://github.com/charmed-hpc/filesystem-charms//charms/filesystem-client/terraform"
  model_uuid  = juju_model.slurm.uuid
}

resource "juju_integration" "provider_to_filesystem" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.[filesystem-provider].app_name
    endpoint = module.[filesystem-provider].provides.filesystem
  }

  application {
    name     = module.filesystem-client.app_name
    endpoint = module.filesystem-client.requires.filesystem
  }
}

module "slurmctld" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"
  model_uuid  = juju_model.slurm.uuid
  units       = 2
}

resource "juju_integration" "filesystem-to-slurmctld" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.provides.mount
  }

  application {
    name     = module.filesystem-client.app_name
    endpoint = module.filesystem-client.requires.mount
  }
}
