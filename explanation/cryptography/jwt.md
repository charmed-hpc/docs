(jwt)=
# JSON Web Tokens (JWT)

Some Slurm charms support [JSON Web Tokens](https://jwt.io/) as an alternative authentication method for a Slurm cluster.

This service is used by the Slurm charms:

- [`slurmctld`](https://charmhub.io/slurmctld)
- [`slurmrestd`](https://charmhub.io/slurmrestd)

A shared private encryption key is required to verify the signature of client tokens. The current method uses RSA with a length of 2048 bits, which is generated using the [`cryptography`](https://pypi.org/project/cryptography/) package for Python.

The [Slurm documentation](https://slurm.schedmd.com/jwt.html) contains more information about the topic.

## Libraries used

- [`cryptography`](https://pypi.org/project/cryptography/), from PyPI.