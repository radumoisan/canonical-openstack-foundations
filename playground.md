# Playground Inventory

- Date: `2026-06-14`
- Student: `radumoisan`
- Cloud: `gce`
- Public IP: `34.40.48.14`
- Region: `europe-west3`
- Zone: `europe-west3-a`
- Purpose: Chapter-by-chapter validation of the OpenStack Foundations lab on a clean deployment

## Lab Network

- Host bridge IP: `192.168.100.1`
- MAAS VM: `192.168.100.3`
- MAAS VM hostname: `maas`
- MAAS VM root filesystem: `36G`, verified after resize

## MAAS Nodes

- `os-juju01`: `Ready`, tag `juju`, system ID `s7beds`
- `os-compute01`: `Ready`, tag `storage`, system ID `xpgwgy`
- `os-compute02`: `Ready`, tag `storage`, system ID `drrqpn`
- `os-compute03`: `Ready`, tag `storage`, system ID `ytgrks`
- `os-compute04`: `Ready`, tag `storage`, system ID `fgsw3g`

## Juju Controller

- Controller: `maas-controller`
- Controller machine: `os-juju01`
- Controller address: `192.168.100.10`
- Juju dashboard unit: `dashboard/0`
- Juju dashboard address: `192.168.100.11:8080`
