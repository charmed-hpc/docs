terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.17.0"
    }
  }
}

data "juju_model" "slurm" {
  name = "slurm"
}

data "juju_application" "sackd" {
  model = data.juju_model.slurm.name
  name  = "sackd"
}

data "juju_application" "slurmd" {
  model = data.juju_model.slurm.name
  name  = "slurmd"
}

module "sssd" {
  source     = "git::https://github.com/canonical/sssd-operator//terraform"
  model_name = data.juju_model.slurm.name
}

resource "juju_integration" "sssd-to-sackd" {
  model = data.juju_model.slurm.name

  application {
    name = module.sssd.app_name
  }

  application {
    name = data.juju_application.sackd.name
  }
}

resource "juju_integration" "sssd-to-slurmd" {
  model = data.juju_model.slurm.name

  application {
    name = module.sssd.app_name
  }

  application {
    name = data.juju_application.slurmd.name
  }
}
