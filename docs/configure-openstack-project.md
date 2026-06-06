# 8. Configure an OpenStack Project

**Description:**

In this section you create and configure a project in OpenStack.

## :material-book-open-page-variant-outline: 8.1 Create an OpenStack Project

**Description:**

In this exercise, you create a new OpenStack project and then create and assign
a new user to it.

**8.1.1 Create a New Project**

```bash
# Change to the home directory and load the OpenStack administrator environment
cd ~ && source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Run the following `openstack` commands in the same shell session after sourcing `~/admin_openrc`.

```bash
# Create a new project named StudentProject in the admin_domain
openstack project create --domain admin_domain --enable --description "Student Project" StudentProject
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------+----------------------------------+
    | Field       | Value                            |
    +-------------+----------------------------------+
    | description | Student Project                  |
    | domain_id   | 20edcdf73fc742d3a2c347118f244ecd |
    | enabled     | True                             |
    | id          | 98b0c6176739443d827d4c51f88afcbe |
    | is_domain   | False                            |
    | name        | StudentProject                   |
    | options     | {}                               |
    | parent_id   | 20edcdf73fc742d3a2c347118f244ecd |
    | tags        | []                               |
    +-------------+----------------------------------+
    ```

!!! note
    The `--domain` flag must appear before the project name positional argument.

**8.1.2 Create and Assign a User to a Project**

```bash
# Create a new user named student and assign it to StudentProject
openstack user create --project StudentProject --email student@example.com --password openstack --enable student --domain admin_domain
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------+----------------------------------+
    | Field               | Value                            |
    +---------------------+----------------------------------+
    | default_project_id  | 98b0c6176739443d827d4c51f88afcbe |
    | domain_id           | 20edcdf73fc742d3a2c347118f244ecd |
    | email               | student@example.com              |
    | enabled             | True                             |
    | id                  | 89ed5796241e4dddb49afd47ed2d08f5 |
    | name                | student                          |
    | options             | {}                               |
    | password_expires_at | None                             |
    +---------------------+----------------------------------+
    ```

```bash
# Assign the student user the Member role on StudentProject
openstack role add --project-domain admin_domain --user-domain admin_domain --user student --project StudentProject Member
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

## :material-book-open-page-variant-outline: 8.2 Configure Access to a Project in OpenStack

**Description:**

In this exercise, you use the student resource file to authenticate as the
student user.

**8.2.1 Use the student resource file**

```bash
# Copy the student openrc files to the home directory
cp os_files/student_* ~/
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Load the student user environment into the current shell
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Run the following `openstack` commands in the same shell session after sourcing `~/student_openrc`.

## :material-book-open-page-variant-outline: 8.3 Generate Key Pairs for Workload Instance Access

**Description:**

In this exercise, you generate a new key pair for workload instance access and
then import an existing public key.

**8.3.1 Generate a New Key Pair**

```bash
# Load the student user environment (if not already loaded)
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Generate a new keypair and save the private key
openstack keypair create student-keypair > ~/.ssh/student-keypair.pem
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Verify the key file was created
ls -al ~/.ssh/student-keypair.pem
```

??? example "Expected result"
    ```bash
    -rw-rw-r-- 1 ubuntu ubuntu 388 Jun  6 11:09 /home/ubuntu/.ssh/student-keypair.pem
    ```

```bash
# Set restrictive permissions on the private key
chmod 600 ~/.ssh/student-keypair.pem
```

??? example "Expected result"
    ```bash
    No output.
    ```

**8.3.2 Import a Public Key**

```bash
# Load the student user environment (if not already loaded)
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Import an existing public key as a keypair named existing-keypair
openstack keypair create --public-key ~/.ssh/id_rsa.pub existing-keypair
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------+-------------------------------------------------+
    | Field       | Value                                           |
    +-------------+-------------------------------------------------+
    | created_at  | None                                            |
    | fingerprint | 39:8a:c0:c3:ff:47:17:2f:9f:7e:1b:98:0b:11:5e:d8 |
    | id          | existing-keypair                                |
    | is_deleted  | None                                            |
    | name        | existing-keypair                                |
    | type        | ssh                                             |
    | user_id     | 89ed5796241e4dddb49afd47ed2d08f5                |
    +-------------+-------------------------------------------------+
    ```

```bash
# List all keypairs for the current user
openstack keypair list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +------------------+-------------------------------------------------+------+
    | Name             | Fingerprint                                     | Type |
    +------------------+-------------------------------------------------+------+
    | existing-keypair | 39:8a:c0:c3:ff:47:17:2f:9f:7e:1b:98:0b:11:5e:d8 | ssh  |
    | student-keypair  | 60:3f:42:a4:19:40:4b:cf:e9:7d:97:bc:a8:04:8e:ef | ssh  |
    +------------------+-------------------------------------------------+------+
    ```

## :material-book-open-page-variant-outline: 8.4 Define a Security Group for ICMP Traffic

**Description:**

In this exercise, you define a security group that allows both incoming and outgoing
ICMP traffic.

!!! note
    By default, when you create a security group it will allow all outgoing IPv4 and IPv6
    traffic. The examples in the following exercises are there to familiarize you with
    the concept of `ingress` and `egress`.

    If you ever do need to restrict egress traffic make sure to remove all default egress
    rules from the security groups you apply to an instance or a port.

**8.4.1 Define a Rule to Allow Incoming ICMP**

```bash
# Load the student user environment (if not already loaded)
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Create a security group for ICMP traffic
openstack security group create --description "Allow ICMP Traffic" StudentProject_Allow_ICMP
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field           | Value                                                                                                                                                                        |
    +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | created_at      | 2026-06-06T11:10:54Z                                                                                                                                                         |
    | description     | Allow ICMP Traffic                                                                                                                                                           |
    | id              | b39a3179-0980-4223-99ee-26316224ba65                                                                                                                                         |
    | name            | StudentProject_Allow_ICMP                                                                                                                                                    |
    | project_id      | 98b0c6176739443d827d4c51f88afcbe                                                                                                                                             |
    | revision_number | 1                                                                                                                                                                            |
    | rules           | created_at='2026-06-06T11:10:54Z', direction='egress', ethertype='IPv6', id='eafc9ca8-5609-4f60-8bcc-c60aa5f80e4c', standard_attr_id='21', updated_at='2026-06-06T11:10:54Z' |
    |                 | created_at='2026-06-06T11:10:54Z', direction='egress', ethertype='IPv4', id='fa0a730e-95d0-42b8-bf6a-4e055a2d6305', standard_attr_id='20', updated_at='2026-06-06T11:10:54Z' |
    | shared          | False                                                                                                                                                                        |
    | stateful        | True                                                                                                                                                                         |
    | tags            | []                                                                                                                                                                           |
    | updated_at      | 2026-06-06T11:10:54Z                                                                                                                                                         |
    +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    ```

```bash
# Add an ICMP ingress rule to the security group
openstack security group rule create --proto icmp StudentProject_Allow_ICMP
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------------+--------------------------------------+
    | Field                   | Value                                |
    +-------------------------+--------------------------------------+
    | belongs_to_default_sg   | False                                |
    | created_at              | 2026-06-06T11:11:07Z                 |
    | description             |                                      |
    | direction               | ingress                              |
    | ether_type              | IPv4                                 |
    | id                      | 64d51d77-95d0-4233-bbfc-c589c7e6b8ab |
    | name                    | None                                 |
    | normalized_cidr         | 0.0.0.0/0                            |
    | port_range_max          | None                                 |
    | port_range_min          | None                                 |
    | project_id              | 98b0c6176739443d827d4c51f88afcbe     |
    | protocol                | icmp                                 |
    | remote_address_group_id | None                                 |
    | remote_group_id         | None                                 |
    | remote_ip_prefix        | 0.0.0.0/0                            |
    | revision_number         | 0                                    |
    | security_group_id       | b39a3179-0980-4223-99ee-26316224ba65 |
    | tags                    | []                                   |
    | updated_at              | 2026-06-06T11:11:07Z                 |
    +-------------------------+--------------------------------------+
    ```

```bash
# Add an ICMP egress rule to the security group
openstack security group rule create --proto icmp --egress StudentProject_Allow_ICMP
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------------+--------------------------------------+
    | Field                   | Value                                |
    +-------------------------+--------------------------------------+
    | belongs_to_default_sg   | False                                |
    | created_at              | 2026-06-06T11:11:17Z                 |
    | description             |                                      |
    | direction               | egress                               |
    | ether_type              | IPv4                                 |
    | id                      | 6f6a9e99-085f-4495-8e60-d5fefa5f4885 |
    | name                    | None                                 |
    | normalized_cidr         | 0.0.0.0/0                            |
    | port_range_max          | None                                 |
    | port_range_min          | None                                 |
    | project_id              | 98b0c6176739443d827d4c51f88afcbe     |
    | protocol                | icmp                                 |
    | remote_address_group_id | None                                 |
    | remote_group_id         | None                                 |
    | remote_ip_prefix        | 0.0.0.0/0                            |
    | revision_number         | 0                                    |
    | security_group_id       | b39a3179-0980-4223-99ee-26316224ba65 |
    | tags                    | []                                   |
    | updated_at              | 2026-06-06T11:11:17Z                 |
    +-------------------------+--------------------------------------+
    ```

```bash
# List the rules in the ICMP security group
openstack security group rule list StudentProject_Allow_ICMP
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+-------------+-----------+-----------+------------+-----------+-----------------------+----------------------+
    | ID                                   | IP Protocol | Ethertype | IP Range  | Port Range | Direction | Remote Security Group | Remote Address Group |
    +--------------------------------------+-------------+-----------+-----------+------------+-----------+-----------------------+----------------------+
    | 64d51d77-95d0-4233-bbfc-c589c7e6b8ab | icmp        | IPv4      | 0.0.0.0/0 |            | ingress   | None                  | None                 |
    | 6f6a9e99-085f-4495-8e60-d5fefa5f4885 | icmp        | IPv4      | 0.0.0.0/0 |            | egress    | None                  | None                 |
    | eafc9ca8-5609-4f60-8bcc-c60aa5f80e4c | None        | IPv6      | ::/0      |            | egress    | None                  | None                 |
    | fa0a730e-95d0-42b8-bf6a-4e055a2d6305 | None        | IPv4      | 0.0.0.0/0 |            | egress    | None                  | None                 |
    +--------------------------------------+-------------+-----------+-----------+------------+-----------+-----------------------+----------------------+
    ```

## :material-book-open-page-variant-outline: 8.5 Define a Security Group for SSH Traffic

**Description:**

In this exercise, you define a security group that allows both incoming and
outgoing SSH traffic.

**8.5.1 Define a Rule to Allow Incoming and Outgoing SSH**

```bash
# Load the student user environment (if not already loaded)
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Create a security group for SSH traffic
openstack security group create --description "Allow SSH Traffic" StudentProject_Allow_SSH
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field           | Value                                                                                                                                                                        |
    +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | created_at      | 2026-06-06T11:11:41Z                                                                                                                                                         |
    | description     | Allow SSH Traffic                                                                                                                                                            |
    | id              | 909a3124-9e04-415d-9135-c6060a6a8c5c                                                                                                                                         |
    | name            | StudentProject_Allow_SSH                                                                                                                                                     |
    | project_id      | 98b0c6176739443d827d4c51f88afcbe                                                                                                                                             |
    | revision_number | 1                                                                                                                                                                            |
    | rules           | created_at='2026-06-06T11:11:41Z', direction='egress', ethertype='IPv4', id='81345ca0-7255-42f8-bdbb-bdf6de285a57', standard_attr_id='25', updated_at='2026-06-06T11:11:41Z' |
    |                 | created_at='2026-06-06T11:11:41Z', direction='egress', ethertype='IPv6', id='c4ebb57c-354e-409a-bc4c-63950f89522f', standard_attr_id='26', updated_at='2026-06-06T11:11:41Z' |
    | shared          | False                                                                                                                                                                        |
    | stateful        | True                                                                                                                                                                         |
    | tags            | []                                                                                                                                                                           |
    | updated_at      | 2026-06-06T11:11:41Z                                                                                                                                                         |
    +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    ```

```bash
# Add a TCP port 22 ingress rule to the SSH security group
openstack security group rule create --proto tcp --dst-port 22 StudentProject_Allow_SSH
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------------+--------------------------------------+
    | Field                   | Value                                |
    +-------------------------+--------------------------------------+
    | belongs_to_default_sg   | False                                |
    | created_at              | 2026-06-06T11:11:52Z                 |
    | description             |                                      |
    | direction               | ingress                              |
    | ether_type              | IPv4                                 |
    | id                      | df2a4e2a-f9ee-493a-b44d-fea23e6e2e17 |
    | name                    | None                                 |
    | normalized_cidr         | 0.0.0.0/0                            |
    | port_range_max          | 22                                   |
    | port_range_min          | 22                                   |
    | project_id              | 98b0c6176739443d827d4c51f88afcbe     |
    | protocol                | tcp                                  |
    | remote_address_group_id | None                                 |
    | remote_group_id         | None                                 |
    | remote_ip_prefix        | 0.0.0.0/0                            |
    | revision_number         | 0                                    |
    | security_group_id       | 909a3124-9e04-415d-9135-c6060a6a8c5c |
    | tags                    | []                                   |
    | updated_at              | 2026-06-06T11:11:52Z                 |
    +-------------------------+--------------------------------------+
    ```

```bash
# Add a TCP port 22 egress rule to the SSH security group
openstack security group rule create --proto tcp --egress --dst-port 22 StudentProject_Allow_SSH
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-------------------------+--------------------------------------+
    | Field                   | Value                                |
    +-------------------------+--------------------------------------+
    | belongs_to_default_sg   | False                                |
    | created_at              | 2026-06-06T11:12:04Z                 |
    | description             |                                      |
    | direction               | egress                               |
    | ether_type              | IPv4                                 |
    | id                      | 57a48131-cd16-4daa-b731-c292ab82cfd6 |
    | name                    | None                                 |
    | normalized_cidr         | 0.0.0.0/0                            |
    | port_range_max          | 22                                   |
    | port_range_min          | 22                                   |
    | project_id              | 98b0c6176739443d827d4c51f88afcbe     |
    | protocol                | tcp                                  |
    | remote_address_group_id | None                                 |
    | remote_group_id         | None                                 |
    | remote_ip_prefix        | 0.0.0.0/0                            |
    | revision_number         | 0                                    |
    | security_group_id       | 909a3124-9e04-415d-9135-c6060a6a8c5c |
    | tags                    | []                                   |
    | updated_at              | 2026-06-06T11:12:04Z                 |
    +-------------------------+--------------------------------------+
    ```

```bash
# List the rules in the SSH security group
openstack security group rule list StudentProject_Allow_SSH
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+-------------+-----------+-----------+------------+-----------+-----------------------+----------------------+
    | ID                                   | IP Protocol | Ethertype | IP Range  | Port Range | Direction | Remote Security Group | Remote Address Group |
    +--------------------------------------+-------------+-----------+-----------+------------+-----------+-----------------------+----------------------+
    | 57a48131-cd16-4daa-b731-c292ab82cfd6 | tcp         | IPv4      | 0.0.0.0/0 | 22:22      | egress    | None                  | None                 |
    | 81345ca0-7255-42f8-bdbb-bdf6de285a57 | None        | IPv4      | 0.0.0.0/0 |            | egress    | None                  | None                 |
    | c4ebb57c-354e-409a-bc4c-63950f89522f | None        | IPv6      | ::/0      |            | egress    | None                  | None                 |
    | df2a4e2a-f9ee-493a-b44d-fea23e6e2e17 | tcp         | IPv4      | 0.0.0.0/0 | 22:22      | ingress   | None                  | None                 |
    +--------------------------------------+-------------+-----------+-----------+------------+-----------+-----------------------+----------------------+
    ```

## :material-book-open-page-variant-outline: 8.6 Define Quotas for a Project

**Description:**

In this exercise, you will modify the quotas for a project.

**8.6.1 Modify a Project's Quotas**

```bash
# Load the OpenStack administrator environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# View the current quotas for StudentProject
openstack quota show StudentProject
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-----------------------+-------+
    | Resource              | Limit |
    +-----------------------+-------+
    | cores                 |    20 |
    | instances             |    10 |
    | ram                   | 51200 |
    | volumes               |    10 |
    | snapshots             |    10 |
    | gigabytes             |  1000 |
    | backups               |    10 |
    | volumes___DEFAULT__   |    -1 |
    | gigabytes___DEFAULT__ |    -1 |
    | snapshots___DEFAULT__ |    -1 |
    | groups                |    10 |
    | trunk                 |    -1 |
    | networks              |    10 |
    | ports                 |    50 |
    | rbac_policies         |    10 |
    | routers               |    10 |
    | subnets               |    10 |
    | subnet_pools          |    -1 |
    | fixed-ips             |    -1 |
    | injected-file-size    | 10240 |
    | injected-path-size    |   255 |
    | injected-files        |     5 |
    | key-pairs             |   100 |
    | properties            |   128 |
    | server-groups         |    10 |
    | server-group-members  |    10 |
    | floating-ips          |    50 |
    | secgroup-rules        |   100 |
    | secgroups             |    10 |
    | backup-gigabytes      |  1000 |
    | per-volume-gigabytes  |    -1 |
    +-----------------------+-------+
    ```

```bash
# Set new quotas for StudentProject
openstack quota set --cores 40 --ram 25600 --instances 20 --volumes 5 --snapshots 5 --floating-ips 10 --secgroups 20 --secgroup-rules 200 StudentProject
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    This command currently defaults to '--force' when modifying network quotas. This behavior will change in a future release. Consider explicitly providing '--force' or '--no-force' options to avoid changes in behavior.
    ```

```bash
# Verify the updated quotas for StudentProject
openstack quota show StudentProject
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-----------------------+-------+
    | Resource              | Limit |
    +-----------------------+-------+
    | cores                 |    40 |
    | instances             |    20 |
    | ram                   | 25600 |
    | volumes               |     5 |
    | snapshots             |     5 |
    | gigabytes             |  1000 |
    | backups               |    10 |
    | volumes___DEFAULT__   |    -1 |
    | gigabytes___DEFAULT__ |    -1 |
    | snapshots___DEFAULT__ |    -1 |
    | groups                |    10 |
    | trunk                 |    -1 |
    | networks              |    10 |
    | ports                 |    50 |
    | rbac_policies         |    10 |
    | routers               |    10 |
    | subnets               |    10 |
    | subnet_pools          |    -1 |
    | fixed-ips             |    -1 |
    | injected-file-size    | 10240 |
    | injected-path-size    |   255 |
    | injected-files        |     5 |
    | key-pairs             |   100 |
    | properties            |   128 |
    | server-groups         |    10 |
    | server-group-members  |    10 |
    | floating-ips          |    10 |
    | secgroup-rules        |   200 |
    | secgroups             |    20 |
    | backup-gigabytes      |  1000 |
    | per-volume-gigabytes  |    -1 |
    +-----------------------+-------+
    ```

## :material-book-open-page-variant-outline: 8.7 Configure Virtual Networks for a Project

**Description:**

In this exercise, you create a private network, subnet and router for a project.

**8.7.1 Create the Tenant Private Network**

```bash
# Load the student user environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Create the tenant private network with MTU 1300
openstack network create StudentProject_Network --mtu 1300
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
    | created_at                | 2026-06-06T11:13:05Z                 |
    | description               |                                      |
    | dns_domain                | None                                 |
    | id                        | 1d6562cd-9027-43ae-a12e-23f767a3eb8c |
    | ipv4_address_scope        | None                                 |
    | ipv6_address_scope        | None                                 |
    | is_default                | False                                |
    | is_vlan_transparent       | None                                 |
    | l2_adjacency              | True                                 |
    | mtu                       | 1300                                 |
    | name                      | StudentProject_Network               |
    | port_security_enabled     | True                                 |
    | project_id                | 98b0c6176739443d827d4c51f88afcbe     |
    | provider:network_type     | None                                 |
    | provider:physical_network | None                                 |
    | provider:segmentation_id  | None                                 |
    | qos_policy_id             | None                                 |
    | revision_number           | 1                                    |
    | router:external           | Internal                             |
    | segments                  | None                                 |
    | shared                    | False                                |
    | status                    | ACTIVE                               |
    | subnets                   |                                      |
    | tags                      |                                      |
    | tenant_id                 | 98b0c6176739443d827d4c51f88afcbe     |
    | updated_at                | 2026-06-06T11:13:05Z                 |
    +---------------------------+--------------------------------------+
    ```

```bash
# Create the private subnet with DHCP and DNS nameservers
openstack subnet create --ip-version 4 --allocation-pool start=10.20.30.10,end=10.20.30.199 --gateway=10.20.30.1 --dhcp --dns-nameserver 192.168.100.3 --dns-nameserver 8.8.8.8 --subnet-range 10.20.30.0/24 --network StudentProject_Network StudentProject_Subnet
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 10.20.30.10-10.20.30.199             |
    | cidr                 | 10.20.30.0/24                        |
    | created_at           | 2026-06-06T11:13:20Z                 |
    | description          |                                      |
    | dns_nameservers      | 192.168.100.3, 8.8.8.8               |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | True                                 |
    | gateway_ip           | 10.20.30.1                           |
    | host_routes          |                                      |
    | id                   | 9d08b128-5e89-4eee-a725-4aaf6e329abd |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | StudentProject_Subnet                |
    | network_id           | 1d6562cd-9027-43ae-a12e-23f767a3eb8c |
    | project_id           | 98b0c6176739443d827d4c51f88afcbe     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | None                                 |
    | tags                 |                                      |
    | updated_at           | 2026-06-06T11:13:20Z                 |
    +----------------------+--------------------------------------+
    ```

```bash
# List the current networks
openstack network list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+------------------------+--------------------------------------+
    | ID                                   | Name                   | Subnets                              |
    +--------------------------------------+------------------------+--------------------------------------+
    | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b | Public_Network         | 1be22b55-8c88-4b9e-8e17-2a931084b052 |
    | 1d6562cd-9027-43ae-a12e-23f767a3eb8c | StudentProject_Network | 9d08b128-5e89-4eee-a725-4aaf6e329abd |
    +--------------------------------------+------------------------+--------------------------------------+
    ```

```bash
# List the current subnets
openstack subnet list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+-----------------------+--------------------------------------+---------------+
    | ID                                   | Name                  | Network                              | Subnet        |
    +--------------------------------------+-----------------------+--------------------------------------+---------------+
    | 9d08b128-5e89-4eee-a725-4aaf6e329abd | StudentProject_Subnet | 1d6562cd-9027-43ae-a12e-23f767a3eb8c | 10.20.30.0/24 |
    +--------------------------------------+-----------------------+--------------------------------------+---------------+
    ```

```bash
# Show details of the private network
openstack network show StudentProject_Network
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
    | created_at                | 2026-06-06T11:13:05Z                 |
    | description               |                                      |
    | dns_domain                | None                                 |
    | id                        | 1d6562cd-9027-43ae-a12e-23f767a3eb8c |
    | ipv4_address_scope        | None                                 |
    | ipv6_address_scope        | None                                 |
    | is_default                | None                                 |
    | is_vlan_transparent       | None                                 |
    | l2_adjacency              | True                                 |
    | mtu                       | 1300                                 |
    | name                      | StudentProject_Network               |
    | port_security_enabled     | True                                 |
    | project_id                | 98b0c6176739443d827d4c51f88afcbe     |
    | provider:network_type     | None                                 |
    | provider:physical_network | None                                 |
    | provider:segmentation_id  | None                                 |
    | qos_policy_id             | None                                 |
    | revision_number           | 2                                    |
    | router:external           | Internal                             |
    | segments                  | None                                 |
    | shared                    | False                                |
    | status                    | ACTIVE                               |
    | subnets                   | 9d08b128-5e89-4eee-a725-4aaf6e329abd |
    | tags                      |                                      |
    | tenant_id                 | 98b0c6176739443d827d4c51f88afcbe     |
    | updated_at                | 2026-06-06T11:13:20Z                 |
    +---------------------------+--------------------------------------+
    ```

```bash
# Show details of the private subnet
openstack subnet show StudentProject_Subnet
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 10.20.30.10-10.20.30.199             |
    | cidr                 | 10.20.30.0/24                        |
    | created_at           | 2026-06-06T11:13:20Z                 |
    | description          |                                      |
    | dns_nameservers      | 192.168.100.3, 8.8.8.8               |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | True                                 |
    | gateway_ip           | 10.20.30.1                           |
    | host_routes          |                                      |
    | id                   | 9d08b128-5e89-4eee-a725-4aaf6e329abd |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | StudentProject_Subnet                |
    | network_id           | 1d6562cd-9027-43ae-a12e-23f767a3eb8c |
    | project_id           | 98b0c6176739443d827d4c51f88afcbe     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | None                                 |
    | tags                 |                                      |
    | updated_at           | 2026-06-06T11:13:20Z                 |
    +----------------------+--------------------------------------+
    ```

**8.7.2 Create a Router to Connect the Networks**

```bash
# Load the student user environment (if not already loaded)
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Create the router
openstack router create StudentProject_Public_Router
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
    | created_at                | 2026-06-06T11:14:15Z                 |
    | description               |                                      |
    | enable_default_route_bfd  | False                                |
    | enable_default_route_ecmp | False                                |
    | enable_ndp_proxy          | None                                 |
    | external_gateway_info     | null                                 |
    | external_gateways         | []                                   |
    | flavor_id                 | None                                 |
    | id                        | bd1ec4ba-3a5b-463b-84df-9d8bd06adf4a |
    | name                      | StudentProject_Public_Router         |
    | project_id                | 98b0c6176739443d827d4c51f88afcbe     |
    | revision_number           | 1                                    |
    | routes                    |                                      |
    | status                    | ACTIVE                               |
    | tags                      |                                      |
    | tenant_id                 | 98b0c6176739443d827d4c51f88afcbe     |
    | updated_at                | 2026-06-06T11:14:15Z                 |
    +---------------------------+--------------------------------------+
    ```

```bash
# Set the router's external gateway to Public_Network
openstack router set --external-gateway Public_Network StudentProject_Public_Router
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Add the private subnet as an interface on the router
openstack router add subnet StudentProject_Public_Router StudentProject_Subnet
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Show the router details to confirm configuration
openstack router show StudentProject_Public_Router
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field                     | Value                                                                                                                                                                                       |
    +---------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | admin_state_up            | UP                                                                                                                                                                                          |
    | availability_zone_hints   |                                                                                                                                                                                             |
    | availability_zones        |                                                                                                                                                                                             |
    | created_at                | 2026-06-06T11:14:15Z                                                                                                                                                                        |
    | description               |                                                                                                                                                                                             |
    | enable_default_route_bfd  | False                                                                                                                                                                                       |
    | enable_default_route_ecmp | False                                                                                                                                                                                       |
    | enable_ndp_proxy          | None                                                                                                                                                                                        |
    | external_gateway_info     | {"network_id": "0c7c4e22-a4ea-4454-b9b1-e5073c72c69b", "external_fixed_ips": [{"subnet_id": "1be22b55-8c88-4b9e-8e17-2a931084b052", "ip_address": "192.168.100.157"}], "enable_snat": true} |
    | external_gateways         | [{'network_id': '0c7c4e22-a4ea-4454-b9b1-e5073c72c69b', 'external_fixed_ips': [{'ip_address': '192.168.100.157', 'subnet_id': '1be22b55-8c88-4b9e-8e17-2a931084b052'}]}]                    |
    | flavor_id                 | None                                                                                                                                                                                        |
    | id                        | bd1ec4ba-3a5b-463b-84df-9d8bd06adf4a                                                                                                                                                        |
    | interfaces_info           | [{"port_id": "a2a00bff-70f6-4bd8-a63b-42f84d7a78a2", "ip_address": "10.20.30.1", "subnet_id": "9d08b128-5e89-4eee-a725-4aaf6e329abd"}]                                                      |
    | name                      | StudentProject_Public_Router                                                                                                                                                                |
    | project_id                | 98b0c6176739443d827d4c51f88afcbe                                                                                                                                                            |
    | revision_number           | 3                                                                                                                                                                                           |
    | routes                    |                                                                                                                                                                                             |
    | status                    | ACTIVE                                                                                                                                                                                      |
    | tags                      |                                                                                                                                                                                             |
    | tenant_id                 | 98b0c6176739443d827d4c51f88afcbe                                                                                                                                                            |
    | updated_at                | 2026-06-06T11:14:46Z                                                                                                                                                                        |
    +---------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    ```

## :material-book-open-page-variant-outline: 8.8 Assign Public IP Addresses to a Project

**Description:**

In this exercise, you allocate a floating IP to a project.

**8.8.1 Allocate a Floating IP to a Project**

```bash
# Load the student user environment (if not already loaded)
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Allocate a floating IP from Public_Network
openstack floating ip create Public_Network
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | created_at          | 2026-06-06T11:15:15Z                 |
    | description         |                                      |
    | dns_domain          |                                      |
    | dns_name            |                                      |
    | fixed_ip_address    | None                                 |
    | floating_ip_address | 192.168.100.180                      |
    | floating_network_id | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b |
    | id                  | 0e04a08a-aa9b-44ed-b26e-f475d6afc9cb |
    | name                | 192.168.100.180                      |
    | port_details        | None                                 |
    | port_id             | None                                 |
    | project_id          | 98b0c6176739443d827d4c51f88afcbe     |
    | qos_policy_id       | None                                 |
    | revision_number     | 0                                    |
    | router_id           | None                                 |
    | status              | DOWN                                 |
    | subnet_id           | None                                 |
    | tags                | []                                   |
    | updated_at          | 2026-06-06T11:15:15Z                 |
    +---------------------+--------------------------------------+
    ```

## :material-book-open-page-variant-outline: 8.9 Web UI Equivalents

This section provides a Web UI alternative to the validated CLI workflow above.
If you already completed the CLI steps, treat this section as optional.

!!! note
    Use the browser proxy path from Chapter 1 and the Horizon access details from Chapter 5 to reach the dashboard at `https://192.168.100.35/horizon`.

**8.9.1 Create a project in OpenStack**

**To create a new project via the WebUI perform the following:**

1. In a web browser, point to the OpenStack Dashboard and log in as the `admin` user.
2. From the panels on the left select `Identity > Projects`.
3. Click `Create Project`:
> On the `Create Project` screen, on the `Project Information` tab, enter the following:
> `Name`: **StudentProject**<br/>
> `Description`: **First Project**<br/>
> `Enabled`: **(checked)**
4. Click `Create Project`.
> You should see the new project listed.

**To create a user and assign them to a project via the WebUI perform the following:**

1. From the panels on the left select `Identity > Users`.
2. Click on `Create User`:
> On the Create User screen, enter/select the following:
> `User Name`: **student**<br/>
> `Email`: **student@example.com**<br/>
> `Password`: **openstack**<br/>
> `Primary Project`: **StudentProject**<br/>
> `Role`: **Member**<br/>
> `Enabled`: **(checked)**
3. Click `Create User`.
> You should see the new user listed
4. Log out of the Dashboard and then log back in as the new `student`.
> You should see only the `Project` and `Identity` panels on the left.

**8.9.2 Configure Access to a Project in OpenStack**

**To create a project user resource file via the WebUI perform the following:**

1. In a web browser, point to the OpenStack Dashboard and log in as `student`.
2. From the panels on the left select: `Project > API Access`.
3. Click on `Download OpenStack RC File` -> `OpenStack RC File`. Rename the RC file to `StudentProject.rc`.
4. Copy the RC file from the system running the web browser to the `ubuntu` account on the MAAS server.
5. At the terminal of the MAAS server, enter the following command to test the `StudentProject.rc` file:

```bash
. ~/StudentProject.rc
```

```bash
openstack catalog list
```

> You should see the endpoints of the cloud services displayed.

!!! note
    When using the resource file downloaded from the WebUI you will be prompted for the project user's password.

**8.9.3 Generate Key Pairs for Workload Instance Access**

**To generate a new keypair via the WebUI perform the following:**

1. In a web browser, point to the OpenStack Dashboard and log in as `student`.
2. From the panels on the left select: `Project > Compute > Key pairs`.
3. You should see a list of existing key pairs. (There are probably none at this point).
4. Click `Create a Key Pair`.
5. In the `Create a Key Pair` screen, enter the following: `Key Pair Name`: `student-keypair`, `Key Type`: `SSH Key`.
6. Click `Create Key Pair`.
7. You should be prompted to download the private key of the newly generated key pair.
> **Important:** It is imperative that you download the key pair when prompted because you will not be able to download it again later.
8. Once downloaded change permissions on the key pair and move it from your Downloads directory to your `~/.ssh/` directory. At the terminal of the vhost enter the following command:

```bash
chmod 600 ~/Downloads/student-keypair.pem
mv ~/Downloads/student-keypair.pem ~/.ssh
```

9. Copy this key to the `~/.ssh` directory of the `ubuntu` user on the `MAAS server`. At the terminal of the vhost enter the following command:

```bash
scp ~/.ssh/student-keypair.pem SHELL_USER@MAAS_IP:~/.ssh
```

**8.9.4 Define a Security Group for ICMP Traffic**

**To define a rule allowing incoming ICMP via the WebUI perform the following:**

1. In a web browser point, to the OpenStack Dashboard and log in as `student`.
2. From the panels on the left select: `Project > Network`.
3. Select the `Security Groups` tab. You should see the existing security groups (probably only default at this point).
4. Click `Create Security Group`.
5. On the `Create Security Group` screen, enter the following:
> `Name`: **StudentProject_Allow_ICMP**<br/>
> `Description`: **Allow ICMP traffic**
6. Click `Create Security Group`. You should see the new security group listed.
7. Next to the `StudentProject_Allow_ICMP` security group, click `Manage Rules`. You should see a list of default rules.
8. Click `Add Rule`.
9. On the `Add Rule` screen, enter/select the following:
> `Rule`: **ALL ICMP**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
10. Click `Add`. You should see your new `Ingress` rule listed.
11. Click `Add Rule` again.
12. On the Add Rule screen, enter/select the following:
> `Rule`: **ALL ICMP**<br/>
> `Direction`: **Egress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**<br/>
13. Click `Add`. You should see your new Egress rule listed.

**8.9.5 Define a Security Group for SSH Traffic**

**To define a rule allowing incoming SSH via the WebUI perform the following:**

1. In a web browser point, to the OpenStack Dashboard and log in as `student`.
2. From the panels on the left select: `Project > Network`.
3. Select the `Security Groups` tab. You should see the existing security groups (probably only default at this point).
4. Click `Create Security Group`.
5. On the `Create Security Group` screen, enter the following:
> `Name`: **StudentProject_Allow_SSH**
> `Description`: **Allow SSH traffic**
6. Click `Create Security Group`. You should see the new security group listed.
7. Next to the `StudentProject_Allow_SSH` security group, click `Manage Rules`. You should see a list of default rules.
8. Click `Add Rule`.
9. On the `Add Rule` screen, enter/select the following:
> `Rule`: **Custom TCP Rule**<br/>
> `Direction`: **Ingress**<br/>
> `Open Port`: **Port**<br/>
> `Port`: **22**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**<br/>
10. Click `Add`. You should see your new `Ingress` rule listed.
11. Click `Add Rule` again.
12. On the `Add Rule` screen, enter/select the following:
> `Rule`: **Custom TCP Rule**<br/>
> `Direction`: **Egress**<br/>
> `Open Port`: **Port**<br/>
> `Port`: **22**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**<br/>
13. Click `Add`. You should see your new `Egress` rule listed.

**8.9.6 Define Quotas for a Project**

**To define quotas for a project via the WebUI perform the following:**

1. Log into the OpenStack Dashboard as the `student`.
2. From the panels on the left, select: `Project > Compute > Overview`.
> In the `Limit Summary` section, notice the number/amount of instances/resource that are available to the project.
3. Log out of the Dashboard and then back in as the `admin` user.
4. From the panels on the left, select: `Identity > Projects`.
5. Next to the `StudentProject` project, in the `Actions` column, from the drop-down list next to `Manage Members`, select `Modify Quotas`.
6. On the `Edit Project` screen on the `Quota` tab, in `Compute`, `Volume` and `Network` modify the values as follows leaving the other values untouched:
> `VCPUs`: **10**<br/>
> `Instances`: **5**<br/>
> `Volumes`: **5**<br/>
> `Volume Snapshots`: **5**<br/>
> `RAM (MB)`: **25600**<br/>
> `Floating IPs`: **10**<br/>
7. Click `Save`.
8. Log out and then back in as the `student`.
9. From the panels on the left, select: `Project > Compute > Overview`.
> In the `Limit Summary` section, notice the changes to the number/amount of instances/resource that are available to the project.

**8.9.7 Configure Virtual Networks for a Project**

**To create a tenant private network via the WebUI perform the following:**

1. Log into the dashboard as the `student` user.
2. From the list of panels on the left select: `Project > Network > Networks`.
3. Click `Create Network`.
4. On the `Create Network` screen `Network` tab, enter/select the following:
> `Name`: **StudentProject_Network**<br/>
> `Enable admin state`: **checked**<br/>
> `Create Subnet`:**(checked)**
5. Click `Next`.
6. On the Create Network screen Subnet tab enter/select the following:
> `Subnet Name`: **StudentProject_Subnet**<br/>
> `Network Address`: **PRIVATE_SUBNET**<br/>
> `IP Version`: **IPv4**<br/>
> `Gateway IP`:**PRIVATE_GATEWAY**<br/>
> `Disable Gateway`: **(unchecked)**<br/>
7. Click `Next`.
8. On the `Create Network` screen `Subnet Details` tab, enter/select the following:
> `Enable DHCP`: **(checked)**<br/>
> `Allocation Pools`: **PRIVATE_IP_START,PRIVATE_IP_END**<br/>
> `DNS Name Servers`: **MAAS_IP NAMESERVERS**<br/>
> `Host Routes`: **(leave blank)**
9. Click `Create`

**To create the router via the WebUI perform the following:**

1. Log into the dashboard as the `student` user.
2. From the list of panels on the left select: `Project > Network > Routers`.
3. Click `Create Router`.
4. On the `Create Router` screen, enter/select the following:
> `Router Name`: **StudentProject_Public_Router**<br/>
> `Enable Admin State`: **checked**<br/>
> `External Network`: **Public_Network**
5. Click `Create Router`.
6. On the `Routers` screen, click on the `StudentProject_Public_Router` in the `Name` column.
7. On the `Routers / StudentProject_Public_Router` screen select the `Interfaces` tab.
8. Click `Add Interface`.
9. On the `Add Interface` screen,enter/select the following:
> `Subnet`: `StudentProject_Network 10.20.30.0/24 (StudentProject_Subnet)`<br/>
> `IP Address (optional)`: **(leave blank)**<br/>
10. Click `Submit`.

**8.9.8 Assign Public IP Addresses to a Project**

**To allocate a floating IP to a project via the WebUI perform the following:**

1. In a web browser, log into the Dashboard as `student`.
2. From the panels on the left select: `Project > Network > Floating IPs`.
3. Click `Allocate IP To Project`.
4. On the `Allocate Floating IP` screen, from the Pool drop-down list, select: `Public_Network`.
5. Click `Allocate IP`. You should see that an IP address has been allocated to the project.
