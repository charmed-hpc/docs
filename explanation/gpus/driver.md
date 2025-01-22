(driver)=
# GPU driver installation and management

## Auto-install

Charmed HPC installs GPU drivers when the `slurmd` charm is deployed on a compute node equipped with a supported Nvidia GPU. Driver detection is performed via the API for [`ubuntu-drivers-common`](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/#the-recommended-way-ubuntu-drivers-tool), a package which examines node hardware, determines appropriate third-party drivers and recommends a set of driver packages that are installed from the Ubuntu repositories.

## Libraries used

- [`ubuntu-drivers-common`](https://github.com/canonical/ubuntu-drivers-common), from GitHub.
