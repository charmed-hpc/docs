(munge)=
# MUNGE

[MUNGE (MUNGE Uid 'N' Gid Emporium)](https://dun.github.io/munge/) is an authentication service for creating and validating credentials.

This service is used by all our Slurm charms, including:

- [`slurmctld`](https://charmhub.io/slurmctld)
- [`slurmd`](https://charmhub.io/slurmd)
- [`slurmdbd`](https://charmhub.io/slurmdbd)
- [`slurmrestd`](https://charmhub.io/slurmrestd)

MUNGE requires sharing a cryptographically secure key between all the Slurm nodes in a cluster. To generate this key, the charms
use the [mungectl](https://github.com/charmed-hpc/mungectl) utility, which uses Go's [`crypto/rand`](https://pkg.go.dev/crypto/rand) library to generate a cryptographically secure key of 1024 bytes of length, using either [`getrandom(2)`](https://man7.org/linux/man-pages/man2/getrandom.2.html) if available, and [`/dev/urandom`](https://en.wikipedia.org/wiki//dev/random) otherwise.

You can find more information about MUNGE on its [official wiki](https://github.com/dun/munge/wiki).

## Packages used

- [`crypto/rand`](https://pkg.go.dev/crypto/rand), from the [Go standard library](https://pkg.go.dev/std).