(contributing-to-docs)=
# Contributing to documentation


## General prerequisites

There are a couple prerequisites to contributing to Charmed HPC's documentation:

* **GitHub Account** The Charmed HPC project uses GitHub to host its documentation. You will need an active GitHub account to report issues and provide contributions. See [Creating an account on GitHub](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github) for more details.

* **Code of Conduct** You will need to read and follow the Ubuntu [Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct). By participating, you implicitly agree to abide by the Code of Conduct.

## How to contribute

### Report an issue

To report an error in spelling, grammar, content, or documentation code functionality, [file an issue](https://github.com/charmed-hpc/docs/issues) in Charmed HPC's bug tracker on GitHub.

### Quick update or new to git

The easiest way to make a quick update, especially for those new to git and GitHub, is to use GitHub's [file editor](https://docs.github.com/en/repositories/working-with-files/managing-files/editing-files#editing-files-in-another-users-repository) via a web browser. 

### Large contribution

For larger, more involved contributions, and those familiar with git and the command line, follow the [fork-and-branch](https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/ process. 

### Test your contribution

To ensure that your contributions meet expectations and pass CI rules, check that they pass the repository's tests.

To install:

```shell
sudo apt install npm snapd
npm install -D @commitlint/cli @commitlint/config-conventional
```

:::{warning}

Make sure to run these commands outside of the repository directory. The commitlint installation process installs a `node_modules` folder that should *not* become part of the docs repository.

:::

To test:

```shell
# Check links
$ make linkcheck

# Check spelling
$ make spelling

# Check inclusive language
$ make woke

# Check accessibility
$ make pa11y

# Ensure style guide compliance
$ make vale

# Ensure commitlint compliance
$ npx commitlint --from <git-commit-from-ID> --to <git-commit-to-ID> --verbose
```

For more information on setting up the tests locally, see [Automatic checks](https://canonical-starter-pack.readthedocs-hosted.com/latest/reference/automatic_checks/) within the Canonical Starter Pack documentation.

:::{note}

The current MAKEFILE setup assumes that you are using an Ubuntu OS. If not, or if running the tests locally is not ideal, you may run them within GitHub. To do so, make sure any local changes have been pushed to your personal fork+branch and are visible from the web interface, then, from the web interface for GitHub:
1. Go to the `Actions` tab 
2. Select the test of interest: `Automatic docs checks` or `docs test`
3. Select `Run workflow`{l=shell} within the workflows panel
4. Select the relevant branch from the drop-down menu
5. Select `Run workflow`{l=shell} within the drop-down

:::

## Documentation structure

### Formatting

#### Diataxis

#### Style guides


