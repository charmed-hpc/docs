:::{dropdown} Tip: How to create a _bundle.pem_ file

You can create your own _bundle.pem_ file with `cat`{l=shell}. For example,
to create a _bundle.pem_ file that contains both the external LDAP server's TLS
certificate and the CA certificate that was used to sign the LDAP server's certificate:

:::{code-block} shell
cat ldap-server.crt ca.crt > bundle.pem
:::

:::
