terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

resource "juju_model" "slurm" {
  name = "slurm"
  cloud {
    name = "charmed-hpc"
  }
}

module "sackd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/sackd/terraform"
  model_uuid  = juju_model.slurm.uuid
}

module "slurmctld" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmctld/terraform"
  model_uuid  = juju_model.slurm.uuid
}

module "slurmd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmd/terraform"
  model_uuid  = juju_model.slurm.uuid
}

module "slurmdbd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmdbd/terraform"
  model_uuid  = juju_model.slurm.uuid
}

module "slurmrestd" {
  source      = "git::https://github.com/charmed-hpc/slurm-charms//charms/slurmrestd/terraform"
  model_uuid  = juju_model.slurm.uuid
}

module "mysql" {
  source          = "git::https://github.com/canonical/mysql-operators//machines/terraform"
  model = juju_model.slurm.uuid
}

resource "juju_integration" "sackd_to_slurmctld" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.sackd.app_name
    endpoint = module.sackd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.login-node
  }
}

resource "juju_integration" "slurmd_to_slurmctld" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.slurmd.app_name
    endpoint = module.slurmd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmd
  }
}

resource "juju_integration" "slurmdbd_to_slurmctld" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.slurmdbd.app_name
    endpoint = module.slurmdbd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmdbd
  }
}

resource "juju_integration" "slurmrestd_to_slurmctld" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.slurmrestd.app_name
    endpoint = module.slurmrestd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.app_name
    endpoint = module.slurmctld.requires.slurmrestd
  }
}

resource "juju_integration" "slurmdbd_to_mysql" {
  model_uuid = juju_model.slurm.uuid

  application {
    name     = module.mysql.app_name
    endpoint = module.mysql.provides.database
  }

  application {
    name     = module.slurmdbd.app_name
    endpoint = module.slurmdbd.requires.database
  }
}
