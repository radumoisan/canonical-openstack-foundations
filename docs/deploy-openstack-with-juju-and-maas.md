# 5. Deploy an OpenStack Cloud with Juju and MAAS

**Description:**

In this section, you use Juju and MAAS to deploy an OpenStack cloud.

## 5.1 Deploy an OpenStack Cloud from a Bundle


**Description:**

In this exercise, you will use Juju to deploy an OpenStack cloud as defined
in the bundle YAML file.

We destroyed our previous controller, so we need to bootstrap a new one.

### Task 1: Deploy OpenStack Cloud from a Bundle

Enter the following command to bootstrap the environment:

```bash
juju bootstrap --config default-base="ubuntu@22.04" \
  --bootstrap-constraints="mem=2G cores=1" \
  --constraints="mem=2G tags=juju" \
  maas maas-controller
```

When the previous command has finished, enter the following command to view the
status of the Juju environment:

```bash
juju status -m controller
```

Enter the following command to create the UOS model for the MAAS cloud:

```bash
juju add-model uos
```

Enter the following command to set the default base for the UOS model:

```bash
juju model-config -m uos default-base=ubuntu@22.04
```

Inspect the OpenStack bundle:

```bash
cat /home/ubuntu/os_files/openstack-bundle.yaml
```

Enter the following command to deploy an OpenStack Cloud from a bundle:

```bash
juju deploy /home/ubuntu/os_files/openstack-bundle.yaml
```

Open another terminal window and make it as wide as possible.

Enter the following command to view the status of the deployment, hit `CTRL+C` to stop the watch command:

```bash
watch -c juju status --color
```

Check the deployment:

```bash
juju status
# output
Model  Controller       Cloud/Region  Version  SLA          Timestamp
uos    maas-controller  maas/default  3.6.2    unsupported  10:38:42Z

App                     Version  Status  Scale  Charm                   Channel           Rev  Exposed  Message
ceph-mon                17.2.7   active      3  ceph-mon                squid/stable   251  no       Unit is ready and clustered
ceph-osd                17.2.7   active      4  ceph-osd                squid/stable   627  no       Unit is ready (1 OSD)
ceph-radosgw            17.2.7   active      1  ceph-radosgw            squid/stable   600  no       Unit is ready
cinder                  20.3.1   active      1  cinder                  2024.1/stable  690  no       Unit is ready
cinder-ceph             20.3.1   active      1  cinder-ceph             2024.1/stable  533  no       Unit is ready
cinder-mysql-router     8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready
dashboard-mysql-router  8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready
glance                  24.2.1   active      1  glance                  2024.1/stable  621  no       Unit is ready
glance-mysql-router     8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready
keystone                21.0.1   active      1  keystone                2024.1/stable  726  no       Application Ready
keystone-mysql-router   8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready
mysql-innodb-cluster    8.0.41   active      3  mysql-innodb-cluster    8.0/stable        158  no       Unit is ready: Mode: R/O, Cluster is ONLINE and can tolerate up to ONE failure.
neutron-api             20.5.0   active      1  neutron-api             2024.1/stable  603  no       Unit is ready
neutron-api-plugin-ovn  20.5.0   active      1  neutron-api-plugin-ovn  2024.1/stable  137  no       Unit is ready
neutron-mysql-router    8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready
nova-cloud-controller   25.2.1   active      1  nova-cloud-controller   2024.1/stable  782  no       Unit is ready
nova-compute            25.2.1   active      4  nova-compute            2024.1/stable  771  no       Unit is ready
nova-mysql-router       8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready
ntp                     4.2      active      4  ntp                     latest/stable      50  no       chrony: Ready
openstack-dashboard     22.1.1   active      1  openstack-dashboard     2024.1/stable  678  no       Unit is ready
ovn-central             22.03.3  active      3  ovn-central             23.09/stable      234  no       Unit is ready (northd: active)
ovn-chassis             22.03.3  active      4  ovn-chassis             23.09/stable      296  no       Unit is ready
placement               7.0.0    active      1  placement               2024.1/stable  102  no       Unit is ready
placement-mysql-router  8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready
rabbitmq-server         3.9.27   active      1  rabbitmq-server         3.9/stable        227  no       Unit is ready
vault                   1.7.9    active      1  vault                   1.7/stable        371  no       Unit is ready (active: true, mlock: disabled)
vault-mysql-router      8.0.41   active      1  mysql-router            8.0/stable        257  no       Unit is ready

Unit                         Workload  Agent  Machine  Public address   Ports           Message
ceph-mon/0                   active    idle   0/lxd/0  192.168.100.19                   Unit is ready and clustered
ceph-mon/1                   active    idle   1/lxd/0  192.168.100.31                   Unit is ready and clustered
ceph-mon/2*                  active    idle   2/lxd/0  192.168.100.144                  Unit is ready and clustered
ceph-osd/0                   active    idle   0        192.168.100.140                  Unit is ready (1 OSD)
ceph-osd/1*                  active    idle   1        192.168.100.141                  Unit is ready (1 OSD)
ceph-osd/2                   active    idle   2        192.168.100.143                  Unit is ready (1 OSD)
ceph-osd/3                   active    idle   3        192.168.100.142                  Unit is ready (1 OSD)
ceph-radosgw/0*              active    idle   0/lxd/1  192.168.100.17   80/tcp          Unit is ready
cinder/0*                    active    idle   1/lxd/1  192.168.100.13   8776/tcp        Unit is ready
  cinder-ceph/0*             active    idle            192.168.100.13                   Unit is ready
  cinder-mysql-router/0*     active    idle            192.168.100.13                   Unit is ready
glance/0*                    active    idle   2/lxd/1  192.168.100.146  9292/tcp        Unit is ready
  glance-mysql-router/0*     active    idle            192.168.100.146                  Unit is ready
keystone/0*                  active    idle   0/lxd/2  192.168.100.18   5000/tcp        Unit is ready
  keystone-mysql-router/0*   active    idle            192.168.100.18                   Unit is ready
mysql-innodb-cluster/0       active    idle   0/lxd/3  192.168.100.37                   Unit is ready: Mode: R/O, Cluster is ONLINE and can tolerate up to ONE failure.
mysql-innodb-cluster/1       active    idle   1/lxd/2  192.168.100.10                   Unit is ready: Mode: R/O, Cluster is ONLINE and can tolerate up to ONE failure.
mysql-innodb-cluster/2*      active    idle   2/lxd/2  192.168.100.145                  Unit is ready: Mode: R/W, Cluster is ONLINE and can tolerate up to ONE failure.
neutron-api/0*               active    idle   1/lxd/3  192.168.100.11   9696/tcp        Unit is ready
  neutron-api-plugin-ovn/0*  active    idle            192.168.100.11                   Unit is ready
  neutron-mysql-router/0*    active    idle            192.168.100.11                   Unit is ready
nova-cloud-controller/0*     active    idle   3/lxd/0  192.168.100.12   8774-8775/tcp   Unit is ready
  nova-mysql-router/0*       active    idle            192.168.100.12                   Unit is ready
nova-compute/0               active    idle   0        192.168.100.140                  Unit is ready
  ntp/0*                     active    idle            192.168.100.140  123/udp         chrony: Ready
  ovn-chassis/0*             active    idle            192.168.100.140                  Unit is ready
nova-compute/1*              active    idle   1        192.168.100.141                  Unit is ready
  ntp/2                      active    idle            192.168.100.141  123/udp         chrony: Ready
  ovn-chassis/2              active    idle            192.168.100.141                  Unit is ready
nova-compute/2               active    idle   2        192.168.100.143                  Unit is ready
  ntp/3                      active    idle            192.168.100.143  123/udp         chrony: Ready
  ovn-chassis/3              active    idle            192.168.100.143                  Unit is ready
nova-compute/3               active    idle   3        192.168.100.142                  Unit is ready
  ntp/1                      active    idle            192.168.100.142  123/udp         chrony: Ready
  ovn-chassis/1              active    idle            192.168.100.142                  Unit is ready
openstack-dashboard/0*       active    idle   3/lxd/1  192.168.100.148  80,443/tcp      Unit is ready
  dashboard-mysql-router/0*  active    idle            192.168.100.148                  Unit is ready
ovn-central/0                active    idle   0/lxd/4  192.168.100.30   6641-6642/tcp   Unit is ready (northd: active)
ovn-central/1                active    idle   1/lxd/4  192.168.100.16   6641-6642/tcp   Unit is ready
ovn-central/2*               active    idle   2/lxd/3  192.168.100.147  6641-6642/tcp   Unit is ready (leader: ovnnb_db, ovnsb_db)
placement/0*                 active    idle   2/lxd/4  192.168.100.39   8778/tcp        Unit is ready
  placement-mysql-router/0*  active    idle            192.168.100.39                   Unit is ready
rabbitmq-server/0*           active    idle   3/lxd/2  192.168.100.149  5672,15672/tcp  Unit is ready
vault/0*                     active    idle   3/lxd/3  192.168.100.14   8200/tcp        Unit is ready (active: true, mlock: disabled)
  vault-mysql-router/0*      active    idle            192.168.100.14                   Unit is ready

Machine  State    Address          Inst id              Base          AZ       Message
0        started  192.168.100.140  os-compute01         ubuntu@22.04  default  Deployed
0/lxd/0  started  192.168.100.19   juju-3d4415-0-lxd-0  ubuntu@22.04  default  Container started
0/lxd/1  started  192.168.100.17   juju-3d4415-0-lxd-1  ubuntu@22.04  default  Container started
0/lxd/2  started  192.168.100.18   juju-3d4415-0-lxd-2  ubuntu@22.04  default  Container started
0/lxd/3  started  192.168.100.37   juju-3d4415-0-lxd-3  ubuntu@22.04  default  Container started
0/lxd/4  started  192.168.100.30   juju-3d4415-0-lxd-4  ubuntu@22.04  default  Container started
1        started  192.168.100.141  os-compute02         ubuntu@22.04  default  Deployed
1/lxd/0  started  192.168.100.31   juju-3d4415-1-lxd-0  ubuntu@22.04  default  Container started
1/lxd/1  started  192.168.100.13   juju-3d4415-1-lxd-1  ubuntu@22.04  default  Container started
1/lxd/2  started  192.168.100.10   juju-3d4415-1-lxd-2  ubuntu@22.04  default  Container started
1/lxd/3  started  192.168.100.11   juju-3d4415-1-lxd-3  ubuntu@22.04  default  Container started
1/lxd/4  started  192.168.100.16   juju-3d4415-1-lxd-4  ubuntu@22.04  default  Container started
2        started  192.168.100.143  os-compute03         ubuntu@22.04  default  Deployed
2/lxd/0  started  192.168.100.144  juju-3d4415-2-lxd-0  ubuntu@22.04  default  Container started
2/lxd/1  started  192.168.100.146  juju-3d4415-2-lxd-1  ubuntu@22.04  default  Container started
2/lxd/2  started  192.168.100.145  juju-3d4415-2-lxd-2  ubuntu@22.04  default  Container started
2/lxd/3  started  192.168.100.147  juju-3d4415-2-lxd-3  ubuntu@22.04  default  Container started
2/lxd/4  started  192.168.100.39   juju-3d4415-2-lxd-4  ubuntu@22.04  default  Container started
3        started  192.168.100.142  os-compute04         ubuntu@22.04  default  Deployed
3/lxd/0  started  192.168.100.12   juju-3d4415-3-lxd-0  ubuntu@22.04  default  Container started
3/lxd/1  started  192.168.100.148  juju-3d4415-3-lxd-1  ubuntu@22.04  default  Container started
3/lxd/2  started  192.168.100.149  juju-3d4415-3-lxd-2  ubuntu@22.04  default  Container started
3/lxd/3  started  192.168.100.14   juju-3d4415-3-lxd-3  ubuntu@22.04  default  Container started
```

For more information on the OpenStack Base bundle, please visit:

https://charmhub.io/openstack-base

For more information on Vault and Certificate management in OpenStack, please
visit:

https://docs.openstack.org/charm-guide/latest/admin/security/tls.html

The env diagram looks like this:

### Task 2: Disable automatic updates

Use `juju ssh` to disable automatic updates on all nodes

```bash
for ((i=0;i<4;i++))
do
  juju ssh $i sudo sysctl kernel.softlockup_panic=0
  juju ssh $i sudo sysctl kernel.hardlockup_panic=0
  juju ssh $i sudo systemctl disable --now apt-daily{,-upgrade}.{timer,service}
  juju ssh $i sudo sed -i \
    \'s/APT::Periodic::Update-Package-Lists.*$/APT::Periodic::Update-Package-Lists \"0\"\;/\' \
    /etc/apt/apt.conf.d/\*
  juju ssh $i sudo sed -i \
    \'s/APT::Periodic::Unattended-Upgrade.*$/APT::Periodic::Unattended-Upgrade \"0\"\;/\' \
    /etc/apt/apt.conf.d/\*
done
```

**Warning:**

Disabling automatic updates is not recommended in your production environment
unless you have an alternative means of keeping your nodes up to date or you need
to follow a very strict patching policy.

### Task 3: Check Ceph Cluster health

Monitor the status of juju and wait for all application relations to be completed.

In a terminal on the `MAAS server`, enter the following commands to view the health
status of the Ceph cluster:

```bash
juju ssh ceph-mon/0 -- sudo ceph health detail
```

```bash
juju ssh ceph-mon/0 -- sudo ceph -s
```

## 5.2 Configure Access to OpenStack

**Description:**

In this exercise, you use interact with the OpenStack Dashboard and CLI.

### Task 1: Interact with the OpenStack Dashboard

On the MAAS server, enter the following command to discover the address of the
OpenStack Dashboard server. This is the IP address you will use to access 
the OpenStack Dashboard:


```bash
juju status openstack-dashboard
```

Open a web browser and point to `http://DASHBOARD_IP/horizon`

You should see the OpenStack Dashboard login page

Log in using the following credentials:
- `Domain`: admin_domain
- `Username`: admin
- `Password `: openstack



### Task 2: Interacting with OpenStack CLI

At the terminal of the MAAS server, enter the following command to retrieve the
IP address of the Keystone Server:


Install the OpenStack CLI tools.

```bash
sudo snap install openstackclients --channel=2024.1/stable --devmode
```

CLI connection in OpenStack is done via `openrc` files which set environment variables for the openstack client to use.

Copy the rc files in `home`.

```bash
cp os_files/admin_openrc* ~/
```

Inspect the files.

```bash
cat ~/admin_openrc
```

```bash
cat ~/admin_openrcv3_project
```

Source the `admin_openrc` file, we will work with it from now on.

```bash
source ~/admin_openrc
```

List the openstack catalog and endpoints.

```bash
openstack catalog list
```

```bash
openstack endpoint list
```




