# 6. Work with Software Defined Networks

**Description:**

In this section, you manage the software defined networks in an OpenStack cloud
using Neutron.

## :material-book-open-page-variant-outline: 6.1 Define the OpenStack External Network

**Description:**

In this exercise, you create the external network for the OpenStack cloud.

**6.1.1 Define the OpenStack External Network**

Run the following commands on the MAAS VM after completing the OpenStack
deployment in Chapter 5.

```bash
# Source the OpenStack administrator credentials
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    No output.
    ```

!!! note
    In this lab environment, each `openstack` command prints `Using Keystone v3 API` before the main command output.

```bash
# Create the external Neutron network on physnet1
openstack network create Public_Network \
        --external \
        --provider-physical-network physnet1 \
        --provider-network-type flat \
        --mtu 1300
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------------+--------------------------------------+
    | Field                     | Value                                |
    +---------------------------+--------------------------------------+
    | admin_state_up            | UP                                   |
    | availability_zone_hints   |                                      |
    | availability_zones        |                                      |
    | created_at                | 2026-06-06T10:00:26Z                 |
    | description               |                                      |
    | dns_domain                | None                                 |
    | id                        | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b |
    | ipv4_address_scope        | None                                 |
    | ipv6_address_scope        | None                                 |
    | is_default                | False                                |
    | is_vlan_transparent       | None                                 |
    | l2_adjacency              | True                                 |
    | mtu                       | 1300                                 |
    | name                      | Public_Network                       |
    | port_security_enabled     | True                                 |
    | project_id                | 045c13c72f32404ebf6c5ed6b2cebbf2     |
    | provider:network_type     | flat                                 |
    | provider:physical_network | physnet1                             |
    | provider:segmentation_id  | None                                 |
    | qos_policy_id             | None                                 |
    | revision_number           | 1                                    |
    | router:external           | External                             |
    | segments                  | None                                 |
    | shared                    | False                                |
    | status                    | ACTIVE                               |
    | subnets                   |                                      |
    | tags                      |                                      |
    | tenant_id                 | 045c13c72f32404ebf6c5ed6b2cebbf2     |
    | updated_at                | 2026-06-06T10:00:26Z                 |
    +---------------------------+--------------------------------------+
    ```

```bash
# List the networks currently defined in OpenStack
openstack network list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+----------------+---------+
    | ID                                   | Name           | Subnets |
    +--------------------------------------+----------------+---------+
    | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b | Public_Network |         |
    +--------------------------------------+----------------+---------+
    ```

```bash
# Show the details of the external network
openstack network show Public_Network
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------------+--------------------------------------+
    | Field                     | Value                                |
    +---------------------------+--------------------------------------+
    | admin_state_up            | UP                                   |
    | availability_zone_hints   |                                      |
    | availability_zones        |                                      |
    | created_at                | 2026-06-06T10:00:26Z                 |
    | description               |                                      |
    | dns_domain                | None                                 |
    | id                        | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b |
    | ipv4_address_scope        | None                                 |
    | ipv6_address_scope        | None                                 |
    | is_default                | False                                |
    | is_vlan_transparent       | None                                 |
    | l2_adjacency              | True                                 |
    | mtu                       | 1300                                 |
    | name                      | Public_Network                       |
    | port_security_enabled     | True                                 |
    | project_id                | 045c13c72f32404ebf6c5ed6b2cebbf2     |
    | provider:network_type     | flat                                 |
    | provider:physical_network | physnet1                             |
    | provider:segmentation_id  | None                                 |
    | qos_policy_id             | None                                 |
    | revision_number           | 1                                    |
    | router:external           | External                             |
    | segments                  | None                                 |
    | shared                    | False                                |
    | status                    | ACTIVE                               |
    | subnets                   |                                      |
    | tags                      |                                      |
    | tenant_id                 | 045c13c72f32404ebf6c5ed6b2cebbf2     |
    | updated_at                | 2026-06-06T10:00:26Z                 |
    +---------------------------+--------------------------------------+
    ```

```bash
# Create the external subnet and reserve the floating IP range
openstack subnet create \
        --ip-version 4 \
        --allocation-pool start=192.168.100.150,end=192.168.100.199 \
        --gateway=192.168.100.1 \
        --no-dhcp \
        --network Public_Network \
        --subnet-range 192.168.100.0/24 \
        Public_Subnet
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 192.168.100.150-192.168.100.199      |
    | cidr                 | 192.168.100.0/24                     |
    | created_at           | 2026-06-06T10:01:05Z                 |
    | description          |                                      |
    | dns_nameservers      |                                      |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | False                                |
    | gateway_ip           | 192.168.100.1                        |
    | host_routes          |                                      |
    | id                   | 1be22b55-8c88-4b9e-8e17-2a931084b052 |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | Public_Subnet                        |
    | network_id           | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b |
    | project_id           | 045c13c72f32404ebf6c5ed6b2cebbf2     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | None                                 |
    | tags                 |                                      |
    | updated_at           | 2026-06-06T10:01:05Z                 |
    +----------------------+--------------------------------------+
    ```

!!! note
    This lab uses the existing `192.168.100.0/24` network as the OpenStack external network on `physnet1`. That overlap is expected in this training environment.

```bash
# List the subnets currently defined in OpenStack
openstack subnet list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+---------------+--------------------------------------+------------------+
    | ID                                   | Name          | Network                              | Subnet           |
    +--------------------------------------+---------------+--------------------------------------+------------------+
    | 1be22b55-8c88-4b9e-8e17-2a931084b052 | Public_Subnet | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b | 192.168.100.0/24 |
    +--------------------------------------+---------------+--------------------------------------+------------------+
    ```

```bash
# Show the details of the external subnet
openstack subnet show Public_Subnet
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 192.168.100.150-192.168.100.199      |
    | cidr                 | 192.168.100.0/24                     |
    | created_at           | 2026-06-06T10:01:05Z                 |
    | description          |                                      |
    | dns_nameservers      |                                      |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | False                                |
    | gateway_ip           | 192.168.100.1                        |
    | host_routes          |                                      |
    | id                   | 1be22b55-8c88-4b9e-8e17-2a931084b052 |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | Public_Subnet                        |
    | network_id           | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b |
    | project_id           | 045c13c72f32404ebf6c5ed6b2cebbf2     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | None                                 |
    | tags                 |                                      |
    | updated_at           | 2026-06-06T10:01:05Z                 |
    +----------------------+--------------------------------------+
    ```

## :material-book-open-page-variant-outline: 6.2 Web UI Equivalents

This section provides a Web UI alternative to the validated CLI workflow above.
If you already completed the network creation with the CLI, treat this section
as optional.

!!! note
    During validation, an unauthenticated request to `http://192.168.100.35/horizon` returned HTTP `302`, which confirmed that the Horizon dashboard was reachable and redirecting to the login page.

**6.2.1 Define the OpenStack External Network via the Web UI**

**To define the external network via the Web UI perform the following:**

1. Open a web browser and point to `http://192.168.100.35/horizon`.
2. Log into the dashboard as the `admin` user.
3. From the list of panels on the left select `Admin > Network > Networks`.
4. Click `Create Network`.
5. On the `Create Network` screen, enter or select the following values:
> `Network Name`: **Public_Network**<br/>
> `Enable Admin State`: **checked**<br/>
> `Shared`: **checked**<br/>
> `Create Subnet`: **unchecked**
6. Click `Create`.
7. In the `Network Name` column, click `Public_Network`.
8. On the `Networks / Public_Network` screen, in the `Subnets` section, click `+Create Subnet`.
9. On the `Create Subnet` screen on the `Subnet` tab, enter or select the following values:
> `Subnet Name`: **Public_Subnet**<br/>
> `Network Address`: `192.168.100.0/24`<br/>
> `IP Version`: **IPv4**<br/>
> `Gateway IP`: **192.168.100.1**<br/>
> `Disable Gateway`: **unchecked**
10. Click `Next`.
11. On the `Subnet Details` tab, enter or select the following values:
> `Enable DHCP`: **unchecked**<br/>
> `Allocation Pools`: **192.168.100.150,192.168.100.199**<br/>
> `Host Routes`: **leave blank**
12. Click `Create`.
