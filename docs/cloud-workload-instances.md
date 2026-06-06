# 9. Work with Cloud Workload Instances

**Description:**

In this section, you use the OpenStack Nova service to launch and work with cloud instances.

## :material-book-open-page-variant-outline: 9.1 Define Custom Instance Sizing Flavors

**Description:**

In this exercise, you create a new instance-sizing flavor.

**9.1.1 Define a New Instance Sizing Flavor**

```bash
# Load the OpenStack administrator environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Run the following `openstack` commands in the same shell session after sourcing `~/admin_openrc`.

```bash
# Create a new instance flavor named m1.smaller
openstack flavor create --vcpus 2 --ram 1024 --disk 5 --ephemeral 0 \
  --swap 0 --public m1.smaller
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------------+--------------------------------------+
    | Field                      | Value                                |
    +----------------------------+--------------------------------------+
    | OS-FLV-DISABLED:disabled   | False                                |
    | OS-FLV-EXT-DATA:ephemeral  | 0                                    |
    | description                | None                                 |
    | disk                       | 5                                    |
    | id                         | f845e849-2cb0-43a8-8906-0ab2f4946fbc |
    | name                       | m1.smaller                           |
    | os-flavor-access:is_public | True                                 |
    | properties                 |                                      |
    | ram                        | 1024                                 |
    | rxtx_factor                | 1.0                                  |
    | swap                       | 0                                    |
    | vcpus                      | 2                                    |
    +----------------------------+--------------------------------------+
    ```

## :material-book-open-page-variant-outline: 9.2 Define Host Aggregates

**Description:**

In this exercise, you create two host aggregates for the compute nodes.

**9.2.1 Define a Host Aggregate**

```bash
# Load the OpenStack administrator environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Create a host aggregate called kvm in the nova availability zone
openstack aggregate create --zone nova kvm
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | availability_zone | nova                                 |
    | created_at        | 2026-06-06T11:23:49.295901           |
    | deleted_at        | None                                 |
    | hosts             | None                                 |
    | id                | 1                                    |
    | is_deleted        | False                                |
    | name              | kvm                                  |
    | properties        | None                                 |
    | updated_at        | None                                 |
    | uuid              | 4aee07e5-b1b6-41f1-b52d-2fc8433e9b54 |
    +-------------------+--------------------------------------+
    ```

```bash
# List the available compute hosts in the nova zone
openstack host list --zone nova
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    API has been deprecated. Please consider using 'hypervisor list' instead.
    +-------------------+---------+------+
    | Host Name         | Service | Zone |
    +-------------------+---------+------+
    | os-compute01.maas | compute | nova |
    | os-compute02.maas | compute | nova |
    | os-compute03.maas | compute | nova |
    | os-compute04.maas | compute | nova |
    +-------------------+---------+------+
    ```

!!! note
    The `openstack host list` command is deprecated. Use `openstack hypervisor list` instead in newer OpenStack releases.

```bash
# Add os-compute01 to the kvm host aggregate
openstack aggregate add host kvm os-compute01.maas
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------+----------------------------+
    | Field             | Value                      |
    +-------------------+----------------------------+
    | availability_zone | nova                       |
    | created_at        | 2026-06-06T11:23:49.000000 |
    | deleted_at        | None                       |
    | hosts             | os-compute01.maas          |
    | id                | 1                          |
    | is_deleted        | False                      |
    | name              | kvm                        |
    | properties        | availability_zone='nova'   |
    | updated_at        | None                       |
    | uuid              | None                       |
    +-------------------+----------------------------+
    ```

```bash
# Add os-compute02 to the kvm host aggregate
openstack aggregate add host kvm os-compute02.maas
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | availability_zone | nova                                 |
    | created_at        | 2026-06-06T11:23:49.000000           |
    | deleted_at        | None                                 |
    | hosts             | os-compute01.maas, os-compute02.maas |
    | id                | 1                                    |
    | is_deleted        | False                                |
    | name              | kvm                                  |
    | properties        | availability_zone='nova'             |
    | updated_at        | None                                 |
    | uuid              | None                                 |
    +-------------------+--------------------------------------+
    ```

```bash
# Add os-compute03 to the kvm host aggregate
openstack aggregate add host kvm os-compute03.maas
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------+---------------------------------------------------------+
    | Field             | Value                                                   |
    +-------------------+---------------------------------------------------------+
    | availability_zone | nova                                                    |
    | created_at        | 2026-06-06T11:23:49.000000                              |
    | deleted_at        | None                                                    |
    | hosts             | os-compute01.maas, os-compute02.maas, os-compute03.maas |
    | id                | 1                                                       |
    | is_deleted        | False                                                   |
    | name              | kvm                                                     |
    | properties        | availability_zone='nova'                                |
    | updated_at        | None                                                    |
    | uuid              | None                                                    |
    +-------------------+---------------------------------------------------------+
    ```

```bash
# Add os-compute04 to the kvm host aggregate
openstack aggregate add host kvm os-compute04.maas
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------+----------------------------------------------------------------------------+
    | Field             | Value                                                                      |
    +-------------------+----------------------------------------------------------------------------+
    | availability_zone | nova                                                                       |
    | created_at        | 2026-06-06T11:23:49.000000                                                 |
    | deleted_at        | None                                                                       |
    | hosts             | os-compute01.maas, os-compute02.maas, os-compute03.maas, os-compute04.maas |
    | id                | 1                                                                          |
    | is_deleted        | False                                                                      |
    | name              | kvm                                                                        |
    | properties        | availability_zone='nova'                                                   |
    | updated_at        | None                                                                       |
    | uuid              | None                                                                       |
    +-------------------+----------------------------------------------------------------------------+
    ```

!!! note
    In this environment, the subshell pattern `$(openstack host list ... | awk ...)` used in the source material does not work due to nested shell quoting. Add each compute host by name directly as shown above.

```bash
# Verify all hosts were added to the kvm aggregate
openstack aggregate show kvm
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------+----------------------------------------------------------------------------+
    | Field             | Value                                                                      |
    +-------------------+----------------------------------------------------------------------------+
    | availability_zone | nova                                                                       |
    | created_at        | 2026-06-06T11:23:49.000000                                                 |
    | deleted_at        | None                                                                       |
    | hosts             | os-compute01.maas, os-compute02.maas, os-compute03.maas, os-compute04.maas |
    | id                | 1                                                                          |
    | is_deleted        | False                                                                      |
    | name              | kvm                                                                        |
    | properties        |                                                                            |
    | updated_at        | None                                                                       |
    | uuid              | 4aee07e5-b1b6-41f1-b52d-2fc8433e9b54                                       |
    +-------------------+----------------------------------------------------------------------------+
    ```

**9.2.2 Define a Key-Value property for a Host Aggregate**

```bash
# Load the OpenStack administrator environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Set the kvm=true property on the kvm host aggregate
openstack aggregate set --property kvm=true kvm
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Verify the property was set on the kvm aggregate
openstack aggregate show kvm
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------+----------------------------------------------------------------------------+
    | Field             | Value                                                                      |
    +-------------------+----------------------------------------------------------------------------+
    | availability_zone | nova                                                                       |
    | created_at        | 2026-06-06T11:23:49.000000                                                 |
    | deleted_at        | None                                                                       |
    | hosts             | os-compute01.maas, os-compute02.maas, os-compute03.maas, os-compute04.maas |
    | id                | 1                                                                          |
    | is_deleted        | False                                                                      |
    | name              | kvm                                                                        |
    | properties        | kvm='true'                                                                 |
    | updated_at        | None                                                                       |
    | uuid              | 4aee07e5-b1b6-41f1-b52d-2fc8433e9b54                                       |
    +-------------------+----------------------------------------------------------------------------+
    ```

## :material-book-open-page-variant-outline: 9.3 Define a Custom Instance Sizing Flavor for a Host Aggregate

**Description:**

In this exercise, you create a new instance-sizing flavor that corresponds to
a host aggregate.

**9.3.1 Define a New Instance Sizing Flavor**

```bash
# Load the OpenStack administrator environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Create a new flavor named kvm.smaller for KVM hypervisors
openstack flavor create --vcpus 1 --ram 512 --disk 5 --public kvm.smaller
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------------+--------------------------------------+
    | Field                      | Value                                |
    +----------------------------+--------------------------------------+
    | OS-FLV-DISABLED:disabled   | False                                |
    | OS-FLV-EXT-DATA:ephemeral  | 0                                    |
    | description                | None                                 |
    | disk                       | 5                                    |
    | id                         | a14c1407-6a49-4e01-974a-9a7168b1f0c8 |
    | name                       | kvm.smaller                          |
    | os-flavor-access:is_public | True                                 |
    | properties                 |                                      |
    | ram                        | 512                                  |
    | rxtx_factor                | 1.0                                  |
    | swap                       | 0                                    |
    | vcpus                      | 1                                    |
    +----------------------------+--------------------------------------+
    ```

```bash
# Set the aggregate_instance_extra_specs property on the kvm.smaller flavor
openstack flavor set --property \
  aggregate_instance_extra_specs:kvm=true kvm.smaller
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Show the kvm.smaller flavor details to verify the property
openstack flavor show kvm.smaller
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------------+-------------------------------------------+
    | Field                      | Value                                     |
    +----------------------------+-------------------------------------------+
    | OS-FLV-DISABLED:disabled   | False                                     |
    | OS-FLV-EXT-DATA:ephemeral  | 0                                         |
    | access_project_ids         | None                                      |
    | description                | None                                      |
    | disk                       | 5                                         |
    | id                         | a14c1407-6a49-4e01-974a-9a7168b1f0c8      |
    | name                       | kvm.smaller                               |
    | os-flavor-access:is_public | True                                      |
    | properties                 | aggregate_instance_extra_specs:kvm='true' |
    | ram                        | 512                                       |
    | rxtx_factor                | 1.0                                       |
    | swap                       | 0                                         |
    | vcpus                      | 1                                         |
    +----------------------------+-------------------------------------------+
    ```

**9.3.2 Enable the Scheduler Filter**

By default, the Controller node does not have the scheduling filter required to do
filtering based on the extra_specs you added to the flavor.

We need to add a special filter called `AggregateInstanceExtraSpecsFilter` to the default list already present
on the `nova-cloud-controller` unit.

```bash
# Get the current scheduler filters from nova-cloud-controller
juju exec -u nova-cloud-controller/0 "grep enabled_filters /etc/nova/nova.conf"
```

??? example "Expected result"
    ```bash
    enabled_filters = ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter,DifferentHostFilter,SameHostFilter
    ```

!!! note
    In this environment, run this command directly on the MAAS VM rather than inside a `bash -lc` subshell, since the `juju` command needs to be available in the current shell context.

```bash
# Set the scheduler-default-filters to include AggregateInstanceExtraSpecsFilter
juju config nova-cloud-controller \
  scheduler-default-filters=ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter,DifferentHostFilter,SameHostFilter,AggregateInstanceExtraSpecsFilter
```

??? example "Expected result"
    ```bash
    No output.
    ```

!!! note
    Replace the filter list above with the actual output from the previous `juju exec` command, appending `,AggregateInstanceExtraSpecsFilter` to the end.

```bash
# Verify the updated scheduler-default-filters configuration
juju config nova-cloud-controller scheduler-default-filters
```

??? example "Expected result"
    ```bash
    ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter,DifferentHostFilter,SameHostFilter,AggregateInstanceExtraSpecsFilter
    ```

```bash
# Wait for the nova-cloud-controller config-changed hook to complete
juju status nova-cloud-controller
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.6.23   unsupported  11:27:30Z

    App                    Version  Status  Scale  Charm                  Channel         Rev  Exposed  Message
    nova-cloud-controller  29.2.0   active      1  nova-cloud-controller  2024.1/stable   795  no       Unit is ready
    nova-mysql-router      8.0.46   active      1  mysql-router           8.0/stable     1136  no       Unit is ready

    Unit                      Workload  Agent      Machine  Public address  Ports          Message
    nova-cloud-controller/0*  active    idle       3/lxd/0  192.168.100.38  8774-8775/tcp  Unit is ready
      nova-mysql-router/0*    active    idle                192.168.100.38                 Unit is ready

    Machine  State    Address         Inst id              Base          AZ       Message
    3        started  192.168.100.26  os-compute04         ubuntu@22.04  default  Deployed
    3/lxd/0  started  192.168.100.38  juju-ed0023-3-lxd-0  ubuntu@22.04  default  Container started
    ```

!!! note
    The unit may briefly show `(config-changed)` in the Message field while the hook runs. Wait until the Agent status shows `idle` before proceeding.

## :material-book-open-page-variant-outline: 9.4 Create a cloud Instance

**Description:**

In this exercise, you will launch a cloud instance.

**9.4.1 Create an Instance**

```bash
# Load the student user environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Run the following `openstack` commands in the same shell session after sourcing `~/student_openrc`.

```bash
# Create a new cloud instance named jammy1
openstack server create --availability-zone nova \
  --image jammy --flavor m1.smaller \
  --key-name student-keypair --security-group StudentProject_Allow_SSH \
  --nic net-id=1d6562cd-9027-43ae-a12e-23f767a3eb8c jammy1
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+---------------------------------------------------+
    | Field                                | Value                                             |
    +--------------------------------------+---------------------------------------------------+
    | OS-DCF:diskConfig                    | MANUAL                                            |
    | OS-EXT-AZ:availability_zone          | nova                                              |
    | OS-EXT-STS:power_state               | NOSTATE                                           |
    | OS-EXT-STS:task_state                | scheduling                                        |
    | OS-EXT-STS:vm_state                  | building                                          |
    | OS-SRV-USG:launched_at               | None                                              |
    | OS-SRV-USG:terminated_at             | None                                              |
    | accessIPv4                           |                                                   |
    | accessIPv6                           |                                                   |
    | addresses                            |                                                   |
    | adminPass                            | fYgtb5qRiJvq                                      |
    | config_drive                         |                                                   |
    | created                              | 2026-06-06T11:28:37Z                              |
    | flavor                               | m1.smaller (f845e849-2cb0-43a8-8906-0ab2f4946fbc) |
    | hostId                               |                                                   |
    | id                                   | e0bc4a2e-389d-4a46-9fe3-4d923903e0e8              |
    | image                                | jammy (0c483320-4a39-43e6-a11a-d7f39bef94e8)      |
    | key_name                             | student-keypair                                   |
    | name                                 | jammy1                                            |
    | os-extended-volumes:volumes_attached | []                                                |
    | progress                             | 0                                                 |
    | project_id                           | 98b0c6176739443d827d4c51f88afcbe                  |
    | properties                           |                                                   |
    | security_groups                      | name='909a3124-9e04-415d-9135-c6060a6a8c5c'       |
    | status                               | BUILD                                             |
    | updated                              | 2026-06-06T11:28:36Z                              |
    | user_id                              | 89ed5796241e4dddb49afd47ed2d08f5                  |
    +--------------------------------------+---------------------------------------------------+
    ```

!!! note
    Replace the `net-id` value above with the actual ID of `StudentProject_Network` from your environment. Get it with `openstack network list | grep StudentProject_Network`.

```bash
# List all instances to check the status of jammy1
openstack server list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+--------+--------+-------------------------------------+-------+------------+
    | ID                                   | Name   | Status | Networks                            | Image | Flavor     |
    +--------------------------------------+--------+--------+-------------------------------------+-------+------------+
    | e0bc4a2e-389d-4a46-9fe3-4d923903e0e8 | jammy1 | ACTIVE | StudentProject_Network=10.20.30.162 | jammy | m1.smaller |
    +--------------------------------------+--------+--------+-------------------------------------+-------+------------+
    ```

!!! note
    Rerun the command periodically until the Status shows `ACTIVE`, or use `watch openstack server list` to monitor in real time.

## :material-book-open-page-variant-outline: 9.5 Expose a Cloud Workload to the External Network

**Description:**

In this exercise, you assign a floating IP address to an instance and edit its
security groups to expose it to the external network.

**9.5.1 Assign a Floating IP to an Instance**

```bash
# Load the student user environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Retrieve the available floating IP address
openstack floating ip list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+
    | ID                                   | Floating IP Address | Fixed IP Address | Port | Floating Network                     | Project                          |
    +--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+
    | 0e04a08a-aa9b-44ed-b26e-f475d6afc9cb | 192.168.100.180     | None             | None | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b | 98b0c6176739443d827d4c51f88afcbe |
    +--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+
    ```

```bash
# Associate the floating IP with the jammy1 instance
openstack server add floating ip jammy1 192.168.100.180
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Verify the floating IP is now associated with a fixed IP
openstack floating ip list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+---------------------+------------------+--------------------------------------+--------------------------------------+----------------------------------+
    | ID                                   | Floating IP Address | Fixed IP Address | Port                                 | Floating Network                     | Project                          |
    +--------------------------------------+---------------------+------------------+--------------------------------------+--------------------------------------+----------------------------------+
    | 0e04a08a-aa9b-44ed-b26e-f475d6afc9cb | 192.168.100.180     | 10.20.30.162     | 4f04aec4-5294-4626-afd7-89d03c06f80c | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b | 98b0c6176739443d827d4c51f88afcbe |
    +--------------------------------------+---------------------+------------------+--------------------------------------+--------------------------------------+----------------------------------+
    ```

**9.5.2 Ping the floating IP**

```bash
# Ping the floating IP address (expected to fail before ICMP is allowed)
ping -c 4 192.168.100.180
```

??? example "Expected result"
    ```bash
    PING 192.168.100.180 (192.168.100.180) 56(84) bytes of data.

    --- 192.168.100.180 ping statistics ---
    4 packets transmitted, 0 received, 100% packet loss, time 3054ms
    ```

!!! note
    The ping fails because the instance is not yet a member of a security group that allows ICMP. The next task adds the instance to the correct security group.

**9.5.3 Edit Instance Security Groups**

```bash
# Load the student user environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Check the current security groups on jammy1
openstack server show jammy1 -c security_groups -f value
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    [{'name': 'StudentProject_Allow_SSH'}]
    ```

```bash
# Add the StudentProject_Allow_ICMP security group to jammy1
openstack server add security group jammy1 StudentProject_Allow_ICMP
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Verify both security groups are now attached to jammy1
openstack server show jammy1 -c security_groups -f value
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    [{'name': 'StudentProject_Allow_SSH'}, {'name': 'StudentProject_Allow_ICMP'}]
    ```

**9.5.4 Ping the floating IP again**

```bash
# Ping the floating IP again (expected to succeed after ICMP is allowed)
ping -c 4 192.168.100.180
```

??? example "Expected result"
    ```bash
    PING 192.168.100.180 (192.168.100.180) 56(84) bytes of data.
    64 bytes from 192.168.100.180: icmp_seq=1 ttl=63 time=4.48 ms
    64 bytes from 192.168.100.180: icmp_seq=2 ttl=63 time=2.82 ms
    64 bytes from 192.168.100.180: icmp_seq=3 ttl=63 time=2.42 ms
    64 bytes from 192.168.100.180: icmp_seq=4 ttl=63 time=4.00 ms

    --- 192.168.100.180 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3005ms
    rtt min/avg/max/mdev = 2.417/3.428/4.477/0.839 ms
    ```

## :material-book-open-page-variant-outline: 9.6 Web UI Equivalents

This section provides a Web UI alternative to the validated CLI workflow above.
If you already completed the CLI steps, treat this section as optional.

!!! note
    Use the browser proxy path from Chapter 1 and the Horizon access details from Chapter 5 to reach the dashboard at `https://192.168.100.35/horizon`.

**9.6.1 Define Custom Instance Sizing Flavors via the Web UI**

**To define a new instance sizing flavor via the Web UI perform the following:**

1. Log into the dashboard as the `admin` user.
2. From the list of tabs on the left select `Admin > Compute > Flavors`.
3. Click `Create Flavor`.
4. On the `Create Flavor` screen, enter or select the following values and leave all unspecified values at their defaults:
> `Name`: **m1.smaller**<br/>
> `ID`: **auto**<br/>
> `VCPUs`: **2**<br/>
> `RAM MB`: **1024**<br/>
> `Root Disk GB`: **5**<br/>
> `Ephemeral Disk GB`: **0**<br/>
> `Swap Disk MB`: **0**<br/>
> `Visibility`: **Public**
5. Click `Create Flavor`. Your new flavor should appear in the list.

**9.6.2 Define Host Aggregates via the Web UI**

**9.6.2.1 Define a Host Aggregate**

**To define a host aggregate via the Web UI perform the following:**

1. Log into the dashboard as the `admin` user.
2. From the list of tabs on the left select `Admin > Compute > Host Aggregates`.
3. Click `Create Host Aggregate`.
4. On the `Create Host Aggregate` screen, enter or select the following:
> `Name`: **kvm**<br/>
> `Availability Zone`: **nova**
5. Click `Create Host Aggregate`.
6. In the `Host Aggregates` list, click the `Add Host` action for the `kvm` aggregate.
7. Select all `os-compute` hosts and move them to the selected column.
8. Click `Add Hosts`.

**9.6.2.2 Define a Key-Value property for a Host Aggregate**

1. Log into the dashboard as the `admin` user.
2. From the list of tabs on the left select `Admin > Compute > Host Aggregates`.
3. In the `Host Aggregates` list, select `Update Metadata` from the dropdown for the `kvm` aggregate.
4. In the `Custom` input box, type `kvm` and click the `+` button.
5. In the `Existing Metadata` column, type `true` in the input box next to `kvm`.
6. Click `Save`. You should see `kvm = true` in the `Metadata` column for the `kvm` host aggregate.

**9.6.3 Define a Custom Instance Sizing Flavor for a Host Aggregate via the Web UI**

**9.6.3.1 Define a New Instance Sizing Flavor**

1. Log into the dashboard as the `admin` user.
2. From the list of tabs on the left select `Admin > Compute > Flavors`.
3. Click `Create Flavor`.
4. On the `Create Flavor` screen, enter or select the following:
> `Name`: **kvm.smaller**<br/>
> `ID`: **auto**<br/>
> `VCPUs`: **1**<br/>
> `RAM MB`: **512**<br/>
> `Root Disk GB`: **5**<br/>
> `Ephemeral Disk GB`: **0**<br/>
> `Swap Disk MB`: **0**<br/>
> `Visibility`: **Public**
5. Click `Create Flavor`. Your new flavor should appear in the list.
6. From the `Actions` dropdown for the `kvm.smaller` flavor, select `Update Metadata`.
7. In the `Custom` input box, type `aggregate_instance_extra_specs:kvm` and click the `+` button.
8. In the `Existing Metadata` column, type `true` in the input box next to `aggregate_instance_extra_specs:kvm`.
9. Click `Save`. You should see the metadata key listed for the `kvm.smaller` flavor.

**9.6.4 Create a cloud Instance via the Web UI**

**9.6.4.1 Create an Instance**

1. Log into the dashboard as the `student` user.
2. From the list of tabs on the left select `Project > Compute > Instances`.
3. Click `Launch Instance`.
4. On the `Launch Instance` screen in the `Details` tab, enter or select the following:
> `Instance Name`: **jammy1**<br/>
> `Availability Zone`: **nova**<br/>
> `Count`: **1**
5. Click `Next`.
6. In the `Source` tab, set `Select Boot Source` to **Image** and `Create New Volume` to **No**.
7. Scroll to the `Available` images and click the up arrow next to the `jammy` image to move it to `Allocated`.
8. Click `Next`.
9. In the `Flavor` tab, click the up arrow next to the `m1.smaller` flavor to move it to `Allocated`.
10. Click `Next`.
11. In the `Networks` tab, click the `+` next to `StudentProject_Network` to move it to `Allocated`.
12. Click `Next` twice.
13. In the `Security Groups` tab, click the up arrow next to `StudentProject_Allow_SSH` to move it to `Allocated`.
14. Click `Next`.
15. In the `Key Pair` tab, click the up arrow next to `student-keypair` to move it to `Allocated`.
16. Click `Launch Instance`.

!!! note
    The instance initially shows status `Build` with task `Block Device Build` and then `Spawning`. It should transition to `Active` status with a power state of `Running` when deployment finishes.

**9.6.5 Expose a Cloud Workload to the External Network via the Web UI**

**9.6.5.1 Assign a Floating IP to an Instance**

**To assign a floating IP via the Web UI perform the following:**

1. Log into the dashboard as the `student` user.
2. From the list of tabs on the left select `Project > Compute > Instances`.
3. Next to the running instance, in the `Actions` column, select `Associate Floating IP` from the dropdown.
4. On the `Manage Floating IP Associations` screen, select the following:
> `IP Address`: **(select the first address in the list)**<br/>
> `Port to be associated`: **(accept the default)**
5. Click `Associate`.
6. The floating IP address should now appear in the `IP Address` column next to the instance.

**9.6.5.2 Edit Instance Security Groups**

**To edit an instance security group via the Web UI perform the following:**

1. Log into the dashboard as the `student` user.
2. Next to the running instance, in the `Actions` column, select `Edit Security Groups` from the dropdown.
3. In the `Edit Instance` window, in the `Security Groups` pane, click the `+` next to `StudentProject_Allow_ICMP`. The security group should move to the `Instance Security Groups` pane.
4. Click `Save`.
