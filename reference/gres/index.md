(gres)=
# Generic Resource (GRES) Scheduling

Each line in _gres.conf_ uses the following parameters to define a GPU resource:

| Parameter  | Value                                                      |
| ---------- | ---------------------------------------------------------- |
| `NodeName` | Node the _gres.conf_ line applies to.                      |
| `Name`     | Name of the generic resource. Always `gpu`.           |
| `Type`     | GPU model name.                                            |
| `File`     | Path of the device file(s) associated with this GPU model. |
