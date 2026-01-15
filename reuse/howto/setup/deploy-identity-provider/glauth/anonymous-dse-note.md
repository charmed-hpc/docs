:::{admonition} GLAuth configuration requirement
:class: note

GLAuth **must** have the `anonymousdse_enabled` configuration option set to
`true` so that SSSD can anonymously inspect the GLAuth server's root directory
server agent service entry (RootDSE) before binding to the GLAuth server.
If `anonymousdse_enabled` is not set to `true`, SSSD will fail to bind to
the GLAuth server as GLAuth will disallow unauthenticated clients from inspecting
its RootDSE.
:::
