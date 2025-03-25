(explanation-rebooting)=
# Instance auto-reboots during install hook

In a Juju model, newly provisioned instances automatically run their respective OS's update and upgrade capabilities by default. This behavior is controlled by [the model configuration](https://documentation.ubuntu.com/juju/latest/user/reference/juju-cli/list-of-juju-cli-commands/model-config/) values `enable-os-refresh-update` and `enable-os-upgrade`. Both configuration values are set to `True` by default.

When a `slurmd` instance is deployed, it will check if a reboot is pending as a result of an automatic upgrade. A pending reboot is signified by the presence of a `/var/run/reboot-required` file. If a reboot is pending, the unit will be immediately rebooted before `slurmd` continues with software installation. This ensures kernel upgrades have been applied before any system drivers are installed.

Following software installation, `slurmd` checks again for a pending reboot. Another reboot may be pending if, for example, GPU drivers have been installed in the instance. In this case, the unit will be rebooted one final time at the end of its install hook.
