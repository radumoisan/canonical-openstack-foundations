# 12. Appendices

## :material-book-open-page-variant-outline: 12.1 Appendix A: Recover from Total Outage

If the cluster experiences a complete outage, some services may remain degraded after the nodes return. This appendix covers the manual recovery steps that may still be required.

Two services need manual intervention in this scenario: `mysql-innodb-cluster` and `vault`.


**12.1.1 Recover the Database Cluster**

Check the status of the database charm. It should be unhealthy after a full outage.

```bash
# Check the mysql-innodb-cluster status
juju status mysql-innodb-cluster
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.5.2    unsupported  06:08:29-05:00

    App                   Version  Status   Scale  Charm                 Channel       Exposed  Rev  OS      Notes
    mysql-innodb-cluster  8.0.37   blocked      3  mysql-innodb-cluster  8.0/stable    no       133  ubuntu

    Unit                     Workload  Agent  Machine  Public address  Ports  Message
    mysql-innodb-cluster/0   blocked   idle   0/lxd/3  192.168.100.54         MySQL InnoDB Cluster not healthy: None
    mysql-innodb-cluster/1*  blocked   idle   1/lxd/2  192.168.100.46         MySQL InnoDB Cluster not healthy: None
    mysql-innodb-cluster/2   blocked   idle   2/lxd/2  192.168.100.52         MySQL InnoDB Cluster not healthy: None

    Machine  State    DNS             Inst id              Base           AZ       Message
    0        started  192.168.100.37  os-compute01         ubuntu@22.04   default  Deployed
    0/lxd/3  started  192.168.100.54  juju-3da275-0-lxd-3  ubuntu@22.04   default  Container started
    1        started  192.168.100.38  os-compute02         ubuntu@22.04   default  Deployed
    1/lxd/2  started  192.168.100.46  juju-3da275-1-lxd-2  ubuntu@22.04   default  Container started
    2        started  192.168.100.39  os-compute03         ubuntu@22.04   default  Deployed
    2/lxd/2  started  192.168.100.52  juju-3da275-2-lxd-2  ubuntu@22.04   default  Container started
    ```

List the available Juju actions for `mysql-innodb-cluster`. Look for `reboot-cluster-from-complete-outage`.

```bash
# List mysql-innodb-cluster recovery actions
juju actions mysql-innodb-cluster
```

??? example "Expected result"
    ```bash
    reboot-cluster-from-complete-outage  Reboot the cluster from this instance's GTID superset after a complete outage.
    ```

Run this action on the leader unit of the charm.

```bash
# Run the complete-outage recovery action on the leader
juju run mysql-innodb-cluster/leader reboot-cluster-from-complete-outage --wait 15m
```

??? example "Expected result"
    ```bash
    Action completed successfully.
    ```

Wait a few minutes for this process to finish and check the cluster status again.

```bash
# Re-check the mysql-innodb-cluster status
juju status mysql-innodb-cluster
```

??? example "Expected result"
    ```bash
    Look for the mysql-innodb-cluster units to return to a healthy state.
    ```

**12.1.2 Unseal Vault**

The Vault charm may need to be unsealed after a complete cluster restart. In this lab, Vault was deployed with `totally-unsecure-auto-unlock`, which is suitable only for testing and not for production.

Check the status of the Vault charm.

```bash
# Check the vault charm status
juju status vault
```

??? example "Expected result"
    ```bash
    Look for vault to report a degraded, blocked, or waiting state before recovery.
    ```

The Vault process inside the LXD container may need a restart after the database is healthy again.

```bash
# Check the vault systemd service state
juju exec --unit vault/0 sudo systemctl status vault
```

??? example "Expected result"
    ```bash
    Look for the vault service state and any recent database connectivity errors.
    ```

```bash
# Restart the vault systemd service
juju exec --unit vault/0 sudo systemctl restart vault
```

??? example "Expected result"
    ```bash
    No output.
    ```

Install the Vault client.

```bash
# Install the Vault CLI client
sudo snap install vault
```

??? example "Expected result"
    ```bash
    vault <channel> from HashiCorp installed
    ```

Now get the unseal key. In a production deployment, Vault typically requires multiple unseal keys. In this lab configuration, a single key is sufficient.

```bash
# Retrieve the Vault leader data and locate the unseal key
juju exec --unit vault/0 leader-get
```

??? example "Expected result"
    ```bash
    keys: '["[REDACTED]"]'
    ```

Unseal Vault using the keys from the file.

```bash
# Export the VAULT_ADDR environment variable
export VAULT_ADDR="http://$(juju exec --unit vault/leader unit-get private-address):8200"
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Unseal Vault with the recovery key
vault operator unseal <unseal key 1>
```

??? example "Expected result"
    ```bash
    Key                Value
    ---                -----
    Sealed             false
    ```

Authorize the vault charm.

```bash
# Export the Vault root token from the saved state file
export VAULT_TOKEN=$(cat /home/ubuntu/vault-state.txt | grep "Initial Root Token" | awk '{print $4}')
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Create a short-lived token for charm authorization
CHARM_TOKEN=$(vault token create -ttl=10m | egrep "^token\s+" | awk '{print $2}')
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Authorize the vault charm with the generated token
juju run --wait 5m vault/leader authorize-charm token=$CHARM_TOKEN
```

??? example "Expected result"
    ```bash
    Action completed successfully.
    ```

Resolve the Vault charm if it is in error state.

```bash
# Resolve the vault unit if it remains in error
juju resolved vault/0
```

??? example "Expected result"
    ```bash
    No output.
    ```

Wait a few minutes for the charm to become active again.

Check the status of the charm.

```bash
# Check the overall model status after Vault recovery
juju status
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.5.2    unsupported  13:43:39Z

    App                 Version  Status  Scale  Charm         Channel     Rev  Exposed  Message
    vault               1.7.9    active      1  vault         1.7/stable  349  no       Unit is ready (active: true, mlock: disabled)
    vault-mysql-router  8.0.37   active      1  mysql-router  8.0/stable  200  no       Unit is ready

    Unit                     Workload  Agent  Machine  Public address  Ports     Message
    vault/0*                 active    idle   3/lxd/3  192.168.100.26  8200/tcp  Unit is ready (active: true, mlock: disabled)
      vault-mysql-router/0*  active    idle            192.168.100.26            Unit is ready

    Machine  State    Address         Inst id              Base          AZ       Message
    3        started  192.168.100.24  os-compute04         ubuntu@22.04  default  Deployed
    3/lxd/3  started  192.168.100.26  juju-c06005-3-lxd-3  ubuntu@22.04  default  Container started
    ```


## :material-book-open-page-variant-outline: 12.2 Appendix B: OpenStack Bundle File

**Description:**

This is the OpenStack deploy bundle used in this course.

```yaml
base: ubuntu@22.04
# *** Please refer to the OpenStack Charms Deployment Guide for more        ***
# *** information.
# *** https://docs.openstack.org/project-deploy-guide/charm-deployment-guide **
variables:
  openstack-origin: &openstack-origin distro
  data-port: &data-port br-ex:eth1
  worker-multiplier: &worker-multiplier 0.25
  osd-devices: &osd-devices /dev/vdb
  expected-osd-count: &expected-osd-count 3
  expected-mon-count: &expected-mon-count 3
machines:
  '0':
    base: ubuntu@22.04
  '1':
    base: ubuntu@22.04
  '2':
    base: ubuntu@22.04
  '3':
    base: ubuntu@22.04
relations:
- - nova-compute:amqp
  - rabbitmq-server:amqp
- - nova-cloud-controller:identity-service
  - keystone:identity-service
- - glance:identity-service
  - keystone:identity-service
- - neutron-api:identity-service
  - keystone:identity-service
- - neutron-api:amqp
  - rabbitmq-server:amqp
- - glance:amqp
  - rabbitmq-server:amqp
- - nova-cloud-controller:image-service
  - glance:image-service
- - nova-compute:image-service
  - glance:image-service
- - nova-cloud-controller:cloud-compute
  - nova-compute:cloud-compute
- - nova-cloud-controller:amqp
  - rabbitmq-server:amqp
- - openstack-dashboard:identity-service
  - keystone:identity-service
- - nova-cloud-controller:neutron-api
  - neutron-api:neutron-api
- - cinder:image-service
  - glance:image-service
- - cinder:amqp
  - rabbitmq-server:amqp
- - cinder:identity-service
  - keystone:identity-service
- - cinder:cinder-volume-service
  - nova-cloud-controller:cinder-volume-service
- - cinder-ceph:storage-backend
  - cinder:storage-backend
- - ceph-mon:client
  - nova-compute:ceph
- - nova-compute:ceph-access
  - cinder-ceph:ceph-access
- - ceph-mon:client
  - cinder-ceph:ceph
- - ceph-mon:client
  - glance:ceph
- - ceph-osd:mon
  - ceph-mon:osd
- - ntp:juju-info
  - nova-compute:juju-info
- - ceph-radosgw:mon
  - ceph-mon:radosgw
- - ceph-radosgw:identity-service
  - keystone:identity-service
- - placement
  - keystone
- - placement
  - nova-cloud-controller
- - keystone:shared-db
  - keystone-mysql-router:shared-db
- - cinder:shared-db
  - cinder-mysql-router:shared-db
- - glance:shared-db
  - glance-mysql-router:shared-db
- - nova-cloud-controller:shared-db
  - nova-mysql-router:shared-db
- - neutron-api:shared-db
  - neutron-mysql-router:shared-db
- - openstack-dashboard:shared-db
  - dashboard-mysql-router:shared-db
- - placement:shared-db
  - placement-mysql-router:shared-db
- - vault:shared-db
  - vault-mysql-router:shared-db
- - keystone-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - cinder-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - nova-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - glance-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - neutron-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - dashboard-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - placement-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - vault-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - neutron-api-plugin-ovn:neutron-plugin
  - neutron-api:neutron-plugin-api-subordinate
- - ovn-central:certificates
  - vault:certificates
- - ovn-central:ovsdb-cms
  - neutron-api-plugin-ovn:ovsdb-cms
- - neutron-api:certificates
  - vault:certificates
- - ovn-chassis:nova-compute
  - nova-compute:neutron-plugin
- - ovn-chassis:certificates
  - vault:certificates
- - ovn-chassis:ovsdb
  - ovn-central:ovsdb
- - vault:certificates
  - neutron-api-plugin-ovn:certificates
- - vault:certificates
  - cinder:certificates
- - vault:certificates
  - glance:certificates
- - vault:certificates
  - keystone:certificates
- - vault:certificates
  - nova-cloud-controller:certificates
- - vault:certificates
  - openstack-dashboard:certificates
- - vault:certificates
  - placement:certificates
- - vault:certificates
  - ceph-radosgw:certificates
applications:
  ceph-mon:
    annotations:
      gui-x: '790'
      gui-y: '1540'
    charm: ch:ceph-mon
    channel: squid/stable
    num_units: 3
    options:
      expected-osd-count: *expected-osd-count
      monitor-count: *expected-mon-count
      source: *openstack-origin
    to:
    - lxd:0
    - lxd:1
    - lxd:2
  ceph-osd:
    annotations:
      gui-x: '1065'
      gui-y: '1540'
    charm: ch:ceph-osd
    channel: squid/stable
    num_units: 4
    options:
      osd-devices: *osd-devices
      source: *openstack-origin
    to:
    - '0'
    - '1'
    - '2'
    - '3'
  ceph-radosgw:
    annotations:
      gui-x: '850'
      gui-y: '900'
    charm: ch:ceph-radosgw
    channel: squid/stable
    num_units: 1
    options:
      source: *openstack-origin
    to:
    - lxd:0
  cinder-mysql-router:
    annotations:
      gui-x: '900'
      gui-y: '1400'
    charm: ch:mysql-router
    channel: 8.0/stable
  cinder:
    annotations:
      gui-x: '980'
      gui-y: '1270'
    charm: ch:cinder
    channel: 2024.1/stable
    num_units: 1
    options:
      block-device: None
      glance-api-version: 2
      worker-multiplier: *worker-multiplier
      openstack-origin: *openstack-origin
    to:
    - lxd:1
  cinder-ceph:
    annotations:
      gui-x: '1120'
      gui-y: '1400'
    charm: ch:cinder-ceph
    channel: 2024.1/stable
    num_units: 0
  glance-mysql-router:
    annotations:
      gui-x: '-290'
      gui-y: '1400'
    charm: ch:mysql-router
    channel: 8.0/stable
  glance:
    annotations:
      gui-x: '-230'
      gui-y: '1270'
    charm: ch:glance
    channel: 2024.1/stable
    num_units: 1
    options:
      worker-multiplier: *worker-multiplier
      openstack-origin: *openstack-origin
      image-conversion: true
    to:
    - lxd:2
  keystone-mysql-router:
    annotations:
      gui-x: '230'
      gui-y: '1400'
    charm: ch:mysql-router
    channel: 8.0/stable
  keystone:
    annotations:
      gui-x: '300'
      gui-y: '1270'
    charm: ch:keystone
    channel: 2024.1/stable
    num_units: 1
    options:
      worker-multiplier: *worker-multiplier
      openstack-origin: *openstack-origin
      admin-password: "openstack"
    to:
    - lxd:0
  neutron-mysql-router:
    annotations:
      gui-x: '505'
      gui-y: '1385'
    charm: ch:mysql-router
    channel: 8.0/stable
  neutron-api-plugin-ovn:
    annotations:
      gui-x: '690'
      gui-y: '1385'
    charm: ch:neutron-api-plugin-ovn
    channel: 2024.1/stable
  neutron-api:
    annotations:
      gui-x: '580'
      gui-y: '1270'
    charm: ch:neutron-api
    channel: 2024.1/stable
    num_units: 1
    options:
      neutron-security-groups: true
      enable-ml2-port-security: true
      flat-network-providers: physnet1
      worker-multiplier: *worker-multiplier
      openstack-origin: *openstack-origin
    to:
    - lxd:1
  placement-mysql-router:
    annotations:
      gui-x: '1320'
      gui-y: '1385'
    charm: ch:mysql-router
    channel: 8.0/stable
  placement:
    annotations:
      gui-x: '1320'
      gui-y: '1270'
    charm: ch:placement
    channel: 2024.1/stable
    num_units: 1
    options:
      worker-multiplier: *worker-multiplier
      openstack-origin: *openstack-origin
    to:
    - lxd:2
  nova-mysql-router:
    annotations:
      gui-x: '-30'
      gui-y: '1385'
    charm: ch:mysql-router
    channel: 8.0/stable
  nova-cloud-controller:
    annotations:
      gui-x: '35'
      gui-y: '1270'
    charm: ch:nova-cloud-controller
    channel: 2024.1/stable
    num_units: 1
    options:
      network-manager: Neutron
      worker-multiplier: *worker-multiplier
      openstack-origin: *openstack-origin
      console-access-protocol: novnc
    to:
    - lxd:3
  nova-compute:
    annotations:
      gui-x: '190'
      gui-y: '890'
    charm: ch:nova-compute
    channel: 2024.1/stable
    num_units: 4
    options:
      config-flags: default_ephemeral_format=ext4
      enable-live-migration: true
      enable-resize: true
      migration-auth-type: ssh
      openstack-origin: *openstack-origin
      virt-type: kvm
      cpu-mode: host-passthrough
    to:
    - '0'
    - '1'
    - '2'
    - '3'
  ntp:
    annotations:
      gui-x: '315'
      gui-y: '1030'
    charm: ch:ntp
    channel: latest/stable
    num_units: 0
  dashboard-mysql-router:
    annotations:
      gui-x: '510'
      gui-y: '1030'
    charm: ch:mysql-router
    channel: 8.0/stable
  openstack-dashboard:
    annotations:
      gui-x: '585'
      gui-y: '900'
    charm: ch:openstack-dashboard
    channel: 2024.1/stable
    num_units: 1
    options:
      openstack-origin: *openstack-origin
    to:
    - lxd:3
  rabbitmq-server:
    annotations:
      gui-x: '300'
      gui-y: '1550'
    charm: ch:rabbitmq-server
    channel: 3.9/stable
    num_units: 1
    to:
    - lxd:3
  mysql-innodb-cluster:
    annotations:
      gui-x: '535'
      gui-y: '1550'
    charm: ch:mysql-innodb-cluster
    channel: 8.0/stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
  ovn-central:
    annotations:
      gui-x: '70'
      gui-y: '1550'
    charm: ch:ovn-central
    channel: 24.03/stable
    num_units: 3
    options:
      source: *openstack-origin
    to:
    - lxd:0
    - lxd:1
    - lxd:2
  ovn-chassis:
    annotations:
      gui-x: '120'
      gui-y: '1030'
    charm: ch:ovn-chassis
    channel: 24.03/stable
    options:
      ovn-bridge-mappings: physnet1:br-ex
      bridge-interface-mappings: *data-port
  vault-mysql-router:
    annotations:
      gui-x: '1535'
      gui-y: '1560'
    charm: ch:mysql-router
    channel: 8.0/stable
  vault:
    annotations:
      gui-x: '1610'
      gui-y: '1430'
    charm: ch:vault
    channel: 1.7/stable
    num_units: 1
    options:
      auto-generate-root-ca-cert: true
      totally-unsecure-auto-unlock: true
    to:
    - lxd:3
```
