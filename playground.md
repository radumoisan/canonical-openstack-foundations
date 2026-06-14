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
- State: destroyed after Chapter 4 cleanup

## Chapter 4 Landscape Validation

- Model: `landscape`
- HAProxy address: `192.168.100.12`
- Final state before cleanup: `haproxy`, `landscape-server`, `postgresql`, and `rabbitmq-server` active
- State: `landscape` model and `maas-controller` destroyed before Chapter 5

## OpenStack Deployment

- Controller: `maas-controller`
- Controller address: `192.168.100.16`
- Model: `uos`
- OpenStack applications: `27/27` active after Chapter 5 deployment
- Horizon URL: `http://192.168.100.22/horizon`
- Keystone public endpoint: `https://192.168.100.32:5000/v3`
- Swift public endpoint: `https://192.168.100.28:443/swift/v1`
- Ceph health: `HEALTH_OK`

## OpenStack Networking

- External network: `Public_Network`
- External subnet: `Public_Subnet`
- Provider physical network: `physnet1`
- Provider network type: `flat`
- MTU: `1300`
- Floating IP pool: `192.168.100.150-192.168.100.199`

## OpenStack Images

- Image: `jammy`
- Image ID: `85bafa79-7d2e-4280-86cf-46e220a53470`
- Status: `active`
- Visibility: `public`
- Disk format: `raw`
- Minimum disk: `3`
- Architecture: `x86_64`
