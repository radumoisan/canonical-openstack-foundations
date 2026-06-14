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

## Student Project

- Project: `StudentProject`
- Project ID: `b41c5cc8e3644c109c9ed30cb03adaa2`
- User: `student`
- User ID: `cd7f304259084c44a33d4d0425a5cd41`
- Keypairs: `student-keypair`, `existing-keypair`
- ICMP security group: `StudentProject_Allow_ICMP` (`3c45f30e-379c-42e9-936e-2dedadcb6cfa`)
- SSH security group: `StudentProject_Allow_SSH` (`d91e0f68-2638-4224-a35f-4f4f2bc7462b`)
- Tenant network: `StudentProject_Network` (`02cb4d86-3911-49d8-85e3-058998e3339f`)
- Tenant subnet: `StudentProject_Subnet` (`58a1963f-283b-48bd-a2aa-c538ead51667`)
- Tenant router: `StudentProject_Public_Router` (`8030e676-ce9c-4f74-b11d-6a3ae9ca83ab`)
- Allocated floating IP: `192.168.100.188` (`e333cf26-cd24-4dd3-8e62-1c9bf64e7d06`)

## Workload Instances

- Flavor: `m1.smaller` (`27e59a80-aff9-42d6-a878-e1d21579b794`)
- Aggregate flavor: `kvm.smaller` (`f751dea9-7f5c-4153-9dba-1cac1295b2bd`)
- Host aggregate: `kvm`, hosts `os-compute01.maas`, `os-compute02.maas`, `os-compute03.maas`, `os-compute04.maas`
- Instance: `jammy1` (`505b0715-3ddd-4b52-ab01-d17f3c8af49a`)
- Instance fixed IP: `10.20.30.59`
- Instance floating IP: `192.168.100.188`
- Instance security groups: `StudentProject_Allow_ICMP`, `StudentProject_Allow_SSH`

## OpenStack Storage

- Volume: `volume1` (`1f01698e-ee63-4b83-acc1-bbac584c2fc8`)
- Volume status: `in-use`
- Attached server: `jammy1`
- Attached device: `/dev/vdb`
- Swift container: `mydata`
- Swift objects: `myfile01.txt`, `myfile02.txt`
- Swift public object validation: `myfile02.txt` downloaded successfully with CA certificate
