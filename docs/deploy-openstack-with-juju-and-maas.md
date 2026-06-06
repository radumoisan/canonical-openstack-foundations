# 5. Deploy OpenStack

**Description:**

In this section, you use Juju and MAAS to deploy an OpenStack cloud.

## :material-book-open-page-variant-outline: 5.1 Deploy an OpenStack Cloud from a Bundle

**Description:**

In this exercise, you use Juju to deploy an OpenStack cloud from the provided bundle file.

!!! note
    This chapter assumes the previous controller was destroyed at the end of Chapter 4. During validation, destroying the previous controller also removed the `juju` tag from the MAAS machines. If bootstrap fails with `No available machine matches constraints`, reapply the `juju` tag to the intended machines in MAAS and retry.

**5.1.1 Deploy OpenStack Cloud from a Bundle**

```bash
# Bootstrap a new Juju controller on the MAAS cloud
juju bootstrap --config default-base="ubuntu@22.04" \
  --bootstrap-constraints="mem=2G cores=1" \
  --constraints="mem=2G tags=juju" \
  maas maas-controller
```

??? example "Expected result"
    ```bash
    Creating Juju controller "maas-controller" on maas/default
    Looking for packaged Juju agent version 3.6.23 for amd64
    Located Juju agent version 3.6.23-ubuntu-amd64 at https://streams.canonical.com/juju/tools/agent/3.6.23/juju-3.6.23-linux-amd64.tgz
    Launching controller instance(s) on maas/default...
        - hyedet (arch=amd64 mem=2G cores=2)
    Installing Juju agent on bootstrap instance
    Waiting for address
    Attempting to connect to 192.168.100.22:22
    Connected to 192.168.100.22
    Running machine configuration script...
    Bootstrap agent now started
    Contacting Juju controller at 192.168.100.22 to verify accessibility...

    Bootstrap complete, controller "maas-controller" is now available
    Controller machines are in the "controller" model

    Now you can run
        juju add-model <model-name>
    to create a new model to deploy workloads.
    ```

```bash
# Check the controller model status after bootstrap
juju status -m controller
```

??? example "Expected result"
    ```bash
    Model       Controller       Cloud/Region  Version  SLA          Timestamp
    controller  maas-controller  maas/default  3.6.23   unsupported  16:32:14Z

    App         Version  Status       Scale  Charm            Channel     Rev  Exposed  Message
    controller           maintenance      1  juju-controller  3.6/stable  230  yes      installing charm software

    Unit           Workload     Agent      Machine  Public address  Ports            Message
    controller/0*  maintenance  executing  0        192.168.100.22  17022,17070/tcp  (install) installing charm software

    Machine  State    Address         Inst id    Base          AZ       Message
    0        started  192.168.100.22  os-juju01  ubuntu@22.04  default
    ```

```bash
# Create the UOS model for the OpenStack deployment
juju add-model uos
```

??? example "Expected result"
    ```bash
    Added 'uos' model on maas/default with credential 'admin' for user 'admin'
    ```

```bash
# Set the default base for the UOS model
juju model-config -m uos default-base=ubuntu@22.04
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Inspect the OpenStack bundle that will be deployed
cat /home/ubuntu/os_files/openstack-bundle.yaml
```

??? example "Expected result"
    ```bash
    base: ubuntu@22.04
    # *** Please refer to the OpenStack Charms Deployment Guide for more        ***
    # *** information.
    # *** https://docs.openstack.org/project-deploy-guide/charm-deployment-guide **
    variables:
      openstack-origin: &openstack-origin cloud:jammy-caracal
      source: &source caracal
      data-port: &data-port br-ex:eth1
      worker-multiplier: &worker-multiplier 1
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
    ...
    ```

```bash
# Deploy the OpenStack bundle into the active model
juju deploy /home/ubuntu/os_files/openstack-bundle.yaml
```

??? example "Expected result"
    ```bash
    Located charm "ceph-mon" in charm-hub, channel squid/stable
    Located charm "ceph-osd" in charm-hub, channel squid/stable
    Located charm "ceph-radosgw" in charm-hub, channel squid/stable
    Located charm "cinder" in charm-hub, channel 2024.1/stable
    Located charm "cinder-ceph" in charm-hub, channel 2024.1/stable
    Located charm "mysql-router" in charm-hub, channel 8.0/stable
    ...
    Located charm "vault" in charm-hub, channel 1.7/stable
    Executing changes:
    - upload charm ceph-mon from charm-hub from channel squid/stable with architecture=amd64
    - deploy application ceph-mon from charm-hub with squid/stable
    ...
    - add new machine 0
    - add new machine 1
    - add new machine 2
    - add new machine 3
    ...
    - add relation nova-compute:amqp - rabbitmq-server:amqp
    ...
    Deploy of bundle completed.
    ```

```bash
# Watch the deployment until all units become active
watch -c juju status --color
```

??? example "Expected result"
    ```bash
    - ceph-mon/0: 192.168.100.28 (agent:idle, workload:active)
    - ceph-osd/0: 192.168.100.23 (agent:idle, workload:active)
    - glance/0: 192.168.100.34 (agent:idle, workload:active) 9292/tcp
    - keystone/0: 192.168.100.29 (agent:executing, workload:active) 5000/tcp
    - neutron-api/0: 192.168.100.39 (agent:idle, workload:active) 9696/tcp
    - nova-cloud-controller/0: 192.168.100.38 (agent:idle, workload:active) 8774-8775/tcp
    - nova-compute/0: 192.168.100.23 (agent:idle, workload:active)
    - openstack-dashboard/0: 192.168.100.35 (agent:idle, workload:active) 80,443/tcp
    - rabbitmq-server/0: 192.168.100.36 (agent:idle, workload:active) 5672,15672/tcp
    - vault/0: 192.168.100.37 (agent:idle, workload:active) 8200/tcp
    ```

!!! note
    Press `Ctrl+C` to exit `watch` once all units show `active` status. In this lab, the deployment took about 60 minutes to settle fully.

```bash
# Review the final deployment state after the bundle settles
juju status
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.6.23   unsupported  17:35:07Z

    App                     Version  Status  Scale  Charm                   Channel         Rev  Exposed  Message
    ceph-mon                19.2.3   active      3  ceph-mon                squid/stable    498  no       Unit is ready and clustered
    ceph-osd                19.2.3   active      4  ceph-osd                squid/stable    734  no       Unit is ready (1 OSD)
    ceph-radosgw            19.2.3   active      1  ceph-radosgw            squid/stable    701  no       Unit is ready
    cinder                  24.2.0   active      1  cinder                  2024.1/stable   733  no       Unit is ready
    cinder-ceph             24.2.0   active      1  cinder-ceph             2024.1/stable   533  no       Unit is ready
    cinder-mysql-router     8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    dashboard-mysql-router  8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    glance                  28.1.0   active      1  glance                  2024.1/stable   642  no       Unit is ready
    glance-mysql-router     8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    keystone                25.0.0   active      1  keystone                2024.1/stable   778  no       Application Ready
    keystone-mysql-router   8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    mysql-innodb-cluster    8.0.46   active      3  mysql-innodb-cluster    8.0/stable      159  no       Unit is ready: Mode: R/W, Cluster is ONLINE and can tolerate up to ONE failure.
    neutron-api             24.1.0   active      1  neutron-api             2024.1/stable   650  no       Unit is ready
    neutron-api-plugin-ovn  24.1.0   active      1  neutron-api-plugin-ovn  2024.1/stable   178  no       Unit is ready
    neutron-mysql-router    8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    nova-cloud-controller   29.2.0   active      1  nova-cloud-controller   2024.1/stable   795  no       Unit is ready
    nova-compute            29.2.0   active      4  nova-compute            2024.1/stable   827  no       Unit is ready
    nova-mysql-router       8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    ntp                     4.2      active      4  ntp                     latest/stable    52  no       chrony: Ready
    openstack-dashboard     24.0.1   active      1  openstack-dashboard     2024.1/stable   728  no       Unit is ready
    ovn-central             24.03.2  active      3  ovn-central             24.03/stable    311  no       Unit is ready (leader: ovnnb_db, ovnsb_db)
    ovn-chassis             24.03.2  active      4  ovn-chassis             24.03/stable    396  no       Unit is ready
    placement               11.0.0   active      1  placement               2024.1/stable   125  no       Unit is ready
    placement-mysql-router  8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    rabbitmq-server         3.9.27   active      1  rabbitmq-server         3.9/stable      286  no       Unit is ready
    vault                   1.7.9    active      1  vault                   1.7/stable      371  no       Unit is ready (active: true, mlock: disabled)
    vault-mysql-router      8.0.46   active      1  mysql-router            8.0/stable     1136  no       Unit is ready
    ```

For more information on the OpenStack Base bundle, visit `https://charmhub.io/openstack-base`.

For more information on Vault and certificate management in OpenStack, visit `https://docs.openstack.org/charm-guide/latest/admin/security/tls.html`.

**5.1.2 Disable automatic updates**

```bash
# Disable soft lockup panic handling on the four OpenStack machines
for ((i=0;i<4;i++)); do juju ssh $i -- sudo sysctl kernel.softlockup_panic=0; done
```

??? example "Expected result"
    ```bash
    kernel.softlockup_panic = 0
    kernel.softlockup_panic = 0
    kernel.softlockup_panic = 0
    kernel.softlockup_panic = 0
    ```

```bash
# Disable hard lockup panic handling on the four OpenStack machines
for ((i=0;i<4;i++)); do juju ssh $i -- sudo sysctl kernel.hardlockup_panic=0; done
```

??? example "Expected result"
    ```bash
    kernel.hardlockup_panic = 0
    kernel.hardlockup_panic = 0
    kernel.hardlockup_panic = 0
    kernel.hardlockup_panic = 0
    ```

```bash
# Disable the apt daily timer and service units on the four OpenStack machines
for ((i=0;i<4;i++)); do juju ssh $i -- sudo systemctl disable --now apt-daily{,-upgrade}.{timer,service}; done
```

??? example "Expected result"
    ```bash
    No output.
    ```

!!! note
    On a first run, `systemctl` may print `Removed ...` lines as it removes the timer symlinks. Re-running the command after the units are already disabled can complete silently.

```bash
# Disable periodic apt package-list updates on the four OpenStack machines
for ((i=0;i<4;i++)); do juju ssh $i -- sudo sed -i '/Update-Package-Lists/s/"[01]"/"0"/' /etc/apt/apt.conf.d/*; done
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Disable unattended-upgrade execution on the four OpenStack machines
for ((i=0;i<4;i++)); do
  juju ssh $i -- sudo sed -i \
    '/Unattended-Upgrade/s/"[01]"/"0"/' \
    /etc/apt/apt.conf.d/*
done
```

??? example "Expected result"
    ```bash
    No output.
    ```

!!! warning
    Disabling automatic updates is not recommended in production unless you have another patching process in place or need to follow a strict maintenance policy.

**5.1.3 Check Ceph cluster health**

```bash
# Check detailed Ceph cluster health from the ceph-mon leader unit
juju ssh ceph-mon/0 -- sudo ceph health detail
```

??? example "Expected result"
    ```bash
    HEALTH_OK
    ```

```bash
# Review the overall Ceph cluster summary
juju ssh ceph-mon/0 -- sudo ceph -s
```

??? example "Expected result"
    ```bash
    cluster:
        id:     9fde5db8-60fe-11f1-9d9b-818b9e2edeef
        health: HEALTH_OK

      services:
        mon: 3 daemons, quorum juju-ed0023-0-lxd-0,juju-ed0023-2-lxd-0,juju-ed0023-1-lxd-0 (age 35m)
        mgr: juju-ed0023-0-lxd-0(active, since 34m), standbys: juju-ed0023-2-lxd-0, juju-ed0023-1-lxd-0
        osd: 4 osds: 4 up (since 34m), 4 in (since 34m)
        rgw: 1 daemon active (1 hosts, 1 zones)

      data:
        pools:   19 pools, 167 pgs
        objects: 194 objects, 454 KiB
        usage:   310 MiB used, 80 GiB / 80 GiB avail
        pgs:     167 active+clean

      io:
        client:   511 B/s rd, 0 op/s rd, 0 op/s wr
    ```

## :material-book-open-page-variant-outline: 5.2 Configure Access to OpenStack

**Description:**

In this exercise, you configure and use the OpenStack CLI.

**5.2.1 Interact with OpenStack CLI**

```bash
# Install the OpenStack client tools on the MAAS VM
sudo snap install openstackclients --channel=2024.1/stable --devmode
```

??? example "Expected result"
    ```bash
    openstackclients (2024.1/stable) 2024.1 from Canonical** installed
    ```

```bash
# Copy the OpenStack RC helper files into the home directory
cp os_files/admin_openrc* ~/
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Inspect the top-level RC helper script
cat ~/admin_openrc
```

??? example "Expected result"
    ```bash
    if [ ! -z $JUJU_MODEL ]; then
      _juju_model_arg="-m $JUJU_MODEL"
    fi
    _keystone_major_version=$(juju status $_juju_model_arg keystone --format yaml| \
        awk '/^    version:/ {print $2; exit}' | cut -f1 -d\.)
    _keystone_preferred_api_version=$(juju config $_juju_model_arg keystone preferred-api-version)

    mkdir -p /home/ubuntu/snap/openstackclients/common
    _root_ca=/home/ubuntu/snap/openstackclients/common/root-ca.crt
    juju exec $_juju_model_arg --unit vault/leader 'leader-get root-ca' > /home/ubuntu/snap/openstackclients/common/root-ca.crt 2>/dev/null

    if [ $_keystone_major_version -ge 13 -o \
         "$_keystone_preferred_api_version" = '3' ]; then
        echo Using Keystone v3 API
        . $(dirname ${BASH_SOURCE[0]})/admin_openrcv3_project
    else
        echo Using Keystone v2.0 API
        . $(dirname ${BASH_SOURCE[0]})/admin_openrcv2
    fi
    ```

```bash
# Inspect the Keystone v3 RC file that exports client environment variables
cat ~/admin_openrcv3_project
```

??? example "Expected result"
    ```bash
    _OS_PARAMS=$(env | awk 'BEGIN {FS="="} /^OS_/ {print $1;}' | paste -sd ' ')
    for param in $_OS_PARAMS; do
        unset $param
    done
    unset _OS_PARAMS

    _keystone_vip=$(juju config $_juju_model_arg keystone vip)
    if [ -n "$_keystone_vip" ]; then
        _keystone_ip=$(echo $_keystone_vip | awk '{print $1}')
    else
        _keystone_ip=$(juju exec $_juju_model_arg --unit keystone/leader -- 'network-get --bind-address public')
    fi
    _password=$(juju exec $_juju_model_arg --unit keystone/leader 'leader-get admin_passwd')

    if [ -s $_root_ca ]; then
        export OS_AUTH_PROTOCOL=https
        export OS_CACERT=${_root_ca}
    fi
    export OS_AUTH_URL=${OS_AUTH_PROTOCOL:-http}://${_keystone_ip}:5000/v3
    export OS_USERNAME=admin
    export OS_PASSWORD=[REDACTED]
    export OS_USER_DOMAIN_NAME=admin_domain
    export OS_PROJECT_DOMAIN_NAME=admin_domain
    export OS_PROJECT_NAME=admin
    export OS_REGION_NAME=RegionOne
    export OS_IDENTITY_API_VERSION=3
    # Swift needs this:
    export OS_AUTH_VERSION=3
    # Gnocchi needs this
    export OS_AUTH_TYPE=password
    ```

```bash
# Load the OpenStack client environment into the current shell
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Run the following `openstack` commands in the same shell session after sourcing `~/admin_openrc`.

```bash
# List the registered OpenStack services
openstack catalog list
```

??? example "Expected result"
    ```bash
    +-----------+--------------+-----------------------------------------------------------------------------+
    | Name      | Type         | Endpoints                                                                   |
    +-----------+--------------+-----------------------------------------------------------------------------+
    | placement | placement    | RegionOne                                                                   |
    |           |              |   admin: https://192.168.100.44:8778                                        |
    |           |              |   internal: https://192.168.100.44:8778                                     |
    |           |              |   public: https://192.168.100.44:8778                                       |
    | keystone  | identity     | RegionOne                                                                   |
    |           |              |   admin: https://192.168.100.29:35357/v3                                    |
    |           |              |   public: https://192.168.100.29:5000/v3                                    |
    |           |              |   internal: https://192.168.100.29:5000/v3                                  |
    | cinderv3  | volumev3     | RegionOne                                                                   |
    |           |              |   internal: https://192.168.100.42:8776/v3/...                              |
    | neutron   | network      | RegionOne                                                                   |
    | s3        | s3           | RegionOne                                                                   |
    | nova      | compute      | RegionOne                                                                   |
    | glance    | image        | RegionOne                                                                   |
    | swift     | object-store | RegionOne                                                                   |
    +-----------+--------------+-----------------------------------------------------------------------------+
    ```

```bash
# List the OpenStack service endpoints
openstack endpoint list
```

??? example "Expected result"
    ```bash
    +----------------------------------+-----------+--------------+--------------+---------+-----------+----------------------------------+
    | ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                              |
    +----------------------------------+-----------+--------------+--------------+---------+-----------+----------------------------------+
    | 01f7058303254035aa7a511fd2c8c154 | RegionOne | placement    | placement    | True    | admin     | https://192.168.100.44:8778      |
    | 1b167dbfa7df4eb2b10d624eb37cd70b | RegionOne | neutron      | network      | True    | admin     | https://192.168.100.39:9696      |
    | 2ad68e7e974a475eb8f999673dc373c7 | RegionOne | nova         | compute      | True    | admin     | https://192.168.100.38:8774/v2.1 |
    | 333bb5db8ebb46039e6712ddcbf034b4 | RegionOne | keystone     | identity     | True    | admin     | https://192.168.100.29:35357/v3  |
    | ...                              | ...       | ...          | ...          | ...     | ...       | ...                              |
    | e848cdc0bb604fc4a5bedb2c1a83a226 | RegionOne | placement    | placement    | True    | public    | https://192.168.100.44:8778      |
    +----------------------------------+-----------+--------------+--------------+---------+-----------+----------------------------------+
    ```

## :material-book-open-page-variant-outline: 5.3 Web UI

**Description:**

In this exercise, you access the Horizon dashboard from a web browser.

**5.3.1 Access Horizon**

```bash
# Discover the OpenStack Dashboard address from the Juju model
juju status openstack-dashboard
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.6.23   unsupported  17:35:58Z

    App                     Version  Status  Scale  Charm                Channel         Rev  Exposed  Message
    dashboard-mysql-router  8.0.46   active      1  mysql-router         8.0/stable     1136  no       Unit is ready
    openstack-dashboard     24.0.1   active      1  openstack-dashboard  2024.1/stable   728  no       Unit is ready

    Unit                         Workload  Agent  Machine  Public address  Ports       Message
    openstack-dashboard/0*       active    idle   3/lxd/1  192.168.100.35  80,443/tcp  Unit is ready
      dashboard-mysql-router/0*  active    idle            192.168.100.35              Unit is ready

    Machine  State    Address         Inst id              Base          AZ       Message
    3        started  192.168.100.26  os-compute04         ubuntu@22.04  default  Deployed
    3/lxd/1  started  192.168.100.35  juju-ed0023-3-lxd-1  ubuntu@22.04  default  Container started
    ```

Open a web browser and point to `https://DASHBOARD_IP/horizon`.

In this validation run, the dashboard URL was `https://192.168.100.35/horizon`.

Log in using the following credentials:
- `Domain`: `admin_domain`
- `Username`: `admin`
- `Password`: `openstack`

!!! note
    Use the browser proxy path from Chapter 1 to reach the internal `192.168.100.0/24` lab network.
