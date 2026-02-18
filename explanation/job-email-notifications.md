(explanation-job-email-notifications)=
# Email notifications for jobs

The Slurm workload manager provides support for email notifications of job status changes. This can
be useful for alerting users that their job has started, ended, failed, or reached other
[supported job states](https://slurm.schedmd.com/sbatch.html#OPT_mail-type).

Charmed HPC facilitates the setup of email notifications by supporting the `smtp` interface in the
`slurmctld` charm. The
[`smtp-integrator`](https://charmhub.io/smtp-integrator) charm can be integrated to enable access to an SMTP server which will then be used for sending the email notifications. Specific steps can be found in the
[Enable job email notifications](howto-job-email-notifications) how-to section.

The [Slurm-Mail](https://github.com/neilmunday/slurm-mail) add-on is used in Charmed HPC. This
provides more detailed statistics on user jobs than standard Slurm emails. Slurm-Mail consists of
two executables: `slurm-spool-mail`, which is run by Slurm to spool notification emails in the
`/var/spool/slurm-mail` directory, and `slurm-send-mail` which is run by `cron` once per minute to
examine the `/var/spool/slurm-mail` directory, query the Slurm accounting database for job
statistics relevant to each spooled email, then send the constructed emails to their intended
recipients.

As the Slurm accounting database is queried for job statistics, **it is essential that Charmed HPC clusters be deployed with a `slurmdbd` accounting database for email notification support to function.**

When a `slurmctld` deployment is integrated with an `smtp-integrator`, Slurm-Mail is automatically
installed and configured to use the SMTP server details provided by the integrator. The `slurmctld`
service is reconfigured to use Slurm-Mail, specifically to use the `slurm-spool-mail` executable as
its [`MailProg`](https://slurm.schedmd.com/slurm.conf.html#OPT_MailProg).
