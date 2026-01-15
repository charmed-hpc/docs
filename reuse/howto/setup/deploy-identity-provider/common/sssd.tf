terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

data "juju_model" "slurm" {
  name  = "slurm"
  owner = "admin"
}

data "juju_application" "sackd" {
  model_uuid = data.juju_model.slurm.uuid
  name       = "sackd"
}

data "juju_application" "slurmd" {
  model_uuid = data.juju_model.slurm.uuid
  name       = "slurmd"
}

module "sssd" {
  source     = "git::https://github.com/canonical/sssd-operator//terraform"
  model_uuid = data.juju_model.slurm.uuid
}

resource "juju_integration" "sssd-to-sackd" {
  model_uuid = data.juju_model.slurm.uuid

  application {
    name = module.sssd.app_name
  }

  application {
    name = data.juju_application.sackd.name
  }
}

resource "juju_integration" "sssd-to-slurmd" {
  model_uuid = data.juju_model.slurm.uuid

  application {
    name = module.sssd.app_name
  }

  application {
    name = data.juju_application.slurmd.name
  }
}
