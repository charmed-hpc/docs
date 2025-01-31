(filesystem-charms)=
# Filesystem Charms



## `filesystem_info`

The [`filesystem_info`](https://charmhub.io/filesystem-client/libraries/filesystem_info) interface
uses URIs to share the mount information between the server and the client. This allows using the same
data format for all filesystem types.

The grammar of the specific shape of URIs used is defined as:

:::{code-block}
key = 1*( unreserved )
value = 1*( unreserved / ":" / "/" / "?" / "#" / "[" / "]" / "@" / "!" / "$"
      / "'" / "(" / ")" / "*" / "+" / "," / ";" )
options = key "=" value ["&" options]

host-port = host [":" port]
hosts = host-port ["," hosts]
authority = [userinfo "@"] "(" hosts ")"

URI = scheme "://" authority path-absolute ["?" options]
:::

Any unspecified grammar rule is specified by [RFC 3986](https://datatracker.ietf.org/doc/html/rfc3986#appendix-A).

### Additional requirements

- The scheme component must identify the type of filesystem that needs to be mounted by the client.
- The userinfo component may contain a user for authentication purposes, but it must not contain
  any password required to authenticate against the filesystem. In other words, the `user:password` syntax is not allowed.
- The hosts component must contain the host or list of hosts encompassing the server. The characters
  `(` and `)` must encompass an array of values, and the character `,` must delimit each host ip or domain name. If only
  a single host is required, the host must still be encompassed by `(` and `)`.
- The path-absolute component may be the exported path of the filesystem.
- The options component may contain any other required data for the specific filesystem type, including but not limited to:
      - Password to authenticate an user (raw or secret based).
      - Cluster identifier.
      - Filesystem identifier.
- Since each filesystem type will require different data on its options component, and it is unknown if more data will be
  required in the future, the scheme component may be used to version different data formats for the same filesystem type,
  which doesn’t introduce any breaking changes.

Any filesystem providers must adhere to both the previously defined grammar and the additional requirements specified.
