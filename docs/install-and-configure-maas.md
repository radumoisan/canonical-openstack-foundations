# 2. Install and Configure MAAS

**Description:**

In this section, you install and configure a MAAS environment.



## :material-book-open-page-variant-outline: 2.1 Install a MAAS Server


**2.1.1 Install MAAS Packages**

Generate an SSH key pair:

```bash
# Generate an SSH key pair
ssh-keygen -t rsa -N "" -q -f ~/.ssh/id_rsa
```

??? example "Expected result"
    ```bash
    No output.
    ```

Copy the SSH key to the MAAS server. Use `ubuntu` as the password:

```bash
# Copy the SSH key to the MAAS server
# password is ubuntu
ssh-copy-id 192.168.100.3
```

??? example "Expected result"
    ```bash
    1 file(s) remaining to be installed.
    Now try logging into the machine, with: ssh '192.168.100.3'

    Number of key(s) added: 1
    ```

Copy the configuration files and bundles that you use later:

```bash
# Copy the configuration files and bundles that you use later
scp -r /home/ubuntu/os_files 192.168.100.3:~
```

??? example "Expected result"
    ```bash
    No output.
    ```


Log in to the MAAS VM:

```bash
# Log in to the MAAS VM
ssh 192.168.100.3
```

??? example "Expected result"
    ```bash
    ubuntu@maas:~$
    ```

Install the MAAS snap:

```bash
# Install the MAAS snap
sudo snap install maas --channel=3.4
```

??? example "Expected result"
    ```bash
    maas (3.4/stable) 3.4.9-14399-g.48cea136e from Canonical** installed
    ```

Install the MAAS test database snap:

```bash
# Install the MAAS test database snap
sudo snap install maas-test-db --channel=3.4
```

??? example "Expected result"
    ```bash
    maas-test-db (3.4/stable) 14.2-29-g.ed8d7f2 from Canonical** installed
    ```

Initialize MAAS as a region and rack controller:

```bash
# Initialize MAAS as a region and rack controller
sudo maas init region+rack --database-uri maas-test-db:///
```

??? example "Expected result"
    ```bash
    MAAS URL [default=http://192.168.100.3:5240/MAAS]:
    MAAS has been set up.

    If you want to configure external authentication or use
    MAAS with Canonical RBAC, please run

      sudo maas configauth

    To create admins when not using external authentication, run

      sudo maas createadmin

    To enable TLS for secured communication, please run

      sudo maas config-tls enable
    ```

!!! note
    Press `Enter` when asked about the MAAS URL.


## :material-book-open-page-variant-outline: 2.2 Perform Initial Configuration of a MAAS Server


**Description:**

In this exercise, you perform the initial configuration steps of a MAAS server
such as creating the administrator user and downloading the boot images, both focal (20.04) and jammy (22.04).


**2.2.1 Create the Administrator User**

Enter the following command to create the administrator account, `ubuntu` is the password:

```bash
# create the administrator account, ubuntu is the password
sudo maas createadmin --username=admin --password=ubuntu --email=admin@example.com
```

??? example "Expected result"
    ```bash
    No output.
    ```


**2.2.2 Log into the MAAS server API via the Command Line Interface**

In a terminal on the MAAS server, while logged in as the `ubuntu`, enter
the following command to retrieve the API key for the MAAS admin user and save
it to the file ```~/maas-apikey```:

```bash
# Save the MAAS API key to ~/maas-apikey
sudo maas apikey --username=admin > ~/maas-apikey
```

??? example "Expected result"
    ```bash
    No output.
    ```

Enter the following command to log into MAAS and create a profile:

```bash
# log into MAAS and create a profile
maas login myprofile http://192.168.100.3:5240/MAAS - < ~/maas-apikey
```

??? example "Expected result"
    ```bash
    You are now logged in to the MAAS server at
    http://192.168.100.3:5240/MAAS/api/2.0/ with the profile name
    'myprofile'.
    ```

Verify that you are logged into the MAAS with the profile name of `myprofile`

```bash
# Verify that you are logged into the MAAS with the profile name of myprofile
maas list
```

??? example "Expected result"
    ```bash
    myprofile http://192.168.100.3:5240/MAAS/api/2.0/ [redacted-api-key]
    ```


**2.2.3 Download the Boot Images**

By default, the "focal" (20.04) Ubuntu LTS is marked for download and we need to also download "jammy" (22.04) release, as well. Download the selected boot images:

```bash
# Add the jammy boot image selection
maas myprofile boot-source-selections create 1 os="ubuntu" release="jammy" arches="amd64" \
  subarches="*" labels="*"
```

??? example "Expected result"
    ```bash
    {
        "os": "ubuntu",
        "release": "jammy",
        "arches": [
            "amd64"
        ],
        "subarches": [
            "*"
        ],
        "labels": [
            "*"
        ],
        "boot_source_id": 1,
        "id": 2,
        "resource_uri": "/MAAS/api/2.0/boot-sources/1/selections/2/"
    }
    ```

Start the boot resource import:

```bash
# Start the boot resource import
maas myprofile boot-resources import
```

??? example "Expected result"
    ```bash
    Import of boot resources started
    ```


**2.2.4 Generate SSH Keys for the MAAS Shell Admin User**

In the terminal on the MAAS server, while logged in as the `ubuntu`,
enter the following command to generate a new SSH key pair:

```bash
# generate a new SSH key pair
ssh-keygen -t rsa -N "" -q -f ~/.ssh/id_rsa
```

??? example "Expected result"
    ```bash
    No output.
    ```


**2.2.5 Upload SSH Keys for the MAAS Shell Admin User into MAAS**


In the terminal of the MAAS server, while logged in as the `ubuntu`,
enter the following command to upload the SSH key generated in `2.2.4`:

```bash
# Upload the SSH key generated in 2.2.4
maas myprofile sshkeys create key="`cat ~/.ssh/id_rsa.pub`"
```

??? example "Expected result"
    ```bash
    {
        "key": "[redacted-public-key]",
        "keysource": null,
        "id": 1
    }
    ```


## :material-book-open-page-variant-outline: 2.3 Configure a MAAS Rack Controller to Manage DHCP


**Description**

In this exercise, you configure a MAAS rack controller to manage DHCP on it's
network. You will also reserve two IP address ranges for use external to MAAS.
Finally, you will configure the DNS servers and kernel parameters to be used by
the MAAS server and any nodes it deploys.


**2.3.1 Enable DHCP and Reserve IP Ranges**

Enabling DHCP and reserving IP ranges can be accomplished via the CLI or the WebUI.


In the terminal of the MAAS server, while logged in as `ubuntu`:

Retrieve the fabric ID of the first fabric:

```bash
# Retrieve the fabric ID of the first fabric
FABRIC_ID=`maas myprofile fabrics read | jq ".[0].id"`
```

??? example "Expected result"
    ```bash
    No output.
    ```

Retrieve the VLAN ID of the first VLAN associated with the fabric ID:

```bash
# Retrieve the VLAN ID of the first VLAN associated with the fabric ID
VLAN_ID=`maas myprofile vlans read $FABRIC_ID | jq ".[0].vid"`
```

??? example "Expected result"
    ```bash
    No output.
    ```

Retrieve the system ID for the primary rack controller:

```bash
# Retrieve the system ID for the primary rack controller
RACK_ID=`maas myprofile rack-controllers read | jq -r ".[0].system_id"`
```

??? example "Expected result"
    ```bash
    {
        "subnet": {
            "name": "192.168.100.0/24",
            "description": "",
            "vlan": {
                "vid": 0,
                "mtu": 1500,
                "dhcp_on": false,
                "external_dhcp": null,
                "relay_vlan": null,
                "space": "undefined",
                "id": 1,
                "fabric": "fabric-0",
                "secondary_rack": null,
                "primary_rack": null,
                "fabric_id": 0,
                "name": "untagged",
                "resource_uri": "/MAAS/api/2.0/vlans/1/"
            },
            "cidr": "192.168.100.0/24",
            "rdns_mode": 2,
            "gateway_ip": "192.168.100.1",
            "dns_servers": [],
            "allow_dns": true,
            "allow_proxy": true,
            "active_discovery": false,
            "managed": true,
            "disabled_boot_architectures": [],
            "id": 1,
            "space": "undefined",
            "resource_uri": "/MAAS/api/2.0/subnets/1/"
        },
        "type": "dynamic",
        "start_ip": "192.168.100.200",
        "end_ip": "192.168.100.254",
        "user": {
            "is_superuser": true,
            "username": "admin",
            "email": "admin@example.com",
            "is_local": true,
            "resource_uri": "/MAAS/api/2.0/users/admin/"
        },
        "comment": "",
        "id": 1,
        "resource_uri": "/MAAS/api/2.0/ipranges/1/"
    }
    ```

Add the Dynamic IP address range that will be used by MAAS for enlistment and commissioning and enable DHCP:

```bash
# Create the dynamic DHCP range
maas myprofile ipranges create type=dynamic \
  start_ip=192.168.100.200 end_ip=192.168.100.254
```

??? example "Expected result"
    ```bash
    {
        "vid": 0,
        "mtu": 1400,
        "dhcp_on": true,
        "external_dhcp": null,
        "relay_vlan": null,
        "space": "undefined",
        "id": 1,
        "fabric": "fabric-0",
        "secondary_rack": null,
        "primary_rack": "cf83c4",
        "fabric_id": 0,
        "name": "untagged",
        "resource_uri": "/MAAS/api/2.0/vlans/1/"
    }
    ```

Enable DHCP:

```bash
# Enable DHCP
maas myprofile vlan update $FABRIC_ID $VLAN_ID \
  primary_rack=$RACK_ID dhcp_on=true mtu=1400
```

??? example "Expected result"
    ```bash
    {
        "subnet": {
            "name": "192.168.100.0/24",
            "description": "",
            "vlan": {
                "vid": 0,
                "mtu": 1400,
                "dhcp_on": true,
                "external_dhcp": null,
                "relay_vlan": null,
                "fabric_id": 0,
                "primary_rack": "cf83c4",
                "name": "untagged",
                "secondary_rack": null,
                "space": "undefined",
                "fabric": "fabric-0",
                "id": 1,
                "resource_uri": "/MAAS/api/2.0/vlans/1/"
            },
            "cidr": "192.168.100.0/24",
            "rdns_mode": 2,
            "gateway_ip": "192.168.100.1",
            "dns_servers": [],
            "allow_dns": true,
            "allow_proxy": true,
            "active_discovery": false,
            "managed": true,
            "disabled_boot_architectures": [],
            "space": "undefined",
            "id": 1,
            "resource_uri": "/MAAS/api/2.0/subnets/1/"
        },
        "type": "reserved",
        "start_ip": "192.168.100.1",
        "end_ip": "192.168.100.9",
        "user": {
            "is_superuser": true,
            "username": "admin",
            "email": "admin@example.com",
            "is_local": true,
            "resource_uri": "/MAAS/api/2.0/users/admin/"
        },
        "comment": "",
        "id": 2,
        "resource_uri": "/MAAS/api/2.0/ipranges/2/"
    }
    ```

Add the static IP address range:

```bash
# Add the static IP address range
maas myprofile ipranges create type=reserved \
  start_ip=192.168.100.1 end_ip=192.168.100.9
```

??? example "Expected result"
    ```bash
    {
        "subnet": {
            "name": "192.168.100.0/24",
            "description": "",
            "vlan": {
                "vid": 0,
                "mtu": 1400,
                "dhcp_on": true,
                "external_dhcp": null,
                "relay_vlan": null,
                "space": "undefined",
                "name": "untagged",
                "primary_rack": "cf83c4",
                "fabric": "fabric-0",
                "id": 1,
                "fabric_id": 0,
                "resource_uri": "/MAAS/api/2.0/vlans/1/"
            },
            "cidr": "192.168.100.0/24",
            "rdns_mode": 2,
            "gateway_ip": "192.168.100.1",
            "dns_servers": [],
            "allow_dns": true,
            "allow_proxy": true,
            "active_discovery": false,
            "managed": true,
            "disabled_boot_architectures": [],
            "space": "undefined",
            "id": 1,
            "resource_uri": "/MAAS/api/2.0/subnets/1/"
        },
        "type": "reserved",
        "start_ip": "192.168.100.150",
        "end_ip": "192.168.100.199",
        "user": {
            "is_superuser": true,
            "username": "admin",
            "email": "admin@example.com",
            "is_local": true,
            "resource_uri": "/MAAS/api/2.0/users/admin/"
        },
        "comment": "",
        "id": 3,
        "resource_uri": "/MAAS/api/2.0/ipranges/3/"
    }
    ```

Add the IP address range that will be used for Floating Ips:

```bash
# Add the IP address range that will be used for Floating Ips
maas myprofile ipranges create type=reserved \
  start_ip=192.168.100.150 end_ip=192.168.100.199
```

??? example "Expected result"
    ```bash
    {
        "subnet": {
            "name": "192.168.100.0/24",
            "description": "",
            "vlan": {
                "vid": 0,
                "mtu": 1400,
                "dhcp_on": true,
                "external_dhcp": null,
                "relay_vlan": null,
                "space": "undefined",
                "name": "untagged",
                "primary_rack": "cf83c4",
                "fabric": "fabric-0",
                "id": 1,
                "fabric_id": 0,
                "resource_uri": "/MAAS/api/2.0/vlans/1/"
            },
            "cidr": "192.168.100.0/24",
            "rdns_mode": 2,
            "gateway_ip": "192.168.100.1",
            "dns_servers": [],
            "allow_dns": true,
            "allow_proxy": true,
            "active_discovery": false,
            "managed": true,
            "disabled_boot_architectures": [],
            "space": "undefined",
            "id": 1,
            "resource_uri": "/MAAS/api/2.0/subnets/1/"
        },
        "type": "reserved",
        "start_ip": "192.168.100.150",
        "end_ip": "192.168.100.199",
        "user": {
            "is_superuser": true,
            "username": "admin",
            "email": "admin@example.com",
            "is_local": true,
            "resource_uri": "/MAAS/api/2.0/users/admin/"
        },
        "comment": "",
        "id": 3,
        "resource_uri": "/MAAS/api/2.0/ipranges/3/"
    }
    ```


**2.3.2 Configure Upstream DNS**

Configuring the upstream DNS can be accomplished via the CLI or the WebUI.


Set the Upstream DNS server with the following command:

```bash
# Set the upstream DNS server
maas myprofile maas set-config name=upstream_dns value="8.8.8.8"
```

??? example "Expected result"
    ```bash
    OK
    ```

**2.3.3 Configure Kernel options for nodes**

Configuring the kernel options that will be supplied to nodes can be accomplished
via the CLI or the WebUI.

Set the kernel options server with the following command:

```bash
# Set the kernel boot options
maas myprofile maas set-config name=kernel_opts value="net.ifnames=0"
```

??? example "Expected result"
    ```bash
    OK
    ```


**2.3.4 Configure Local DNS Resolution**

In the terminal of the MAAS server, while logged in as the `ubuntu`, set the DNS and search domain to point to the MAAS server.

Back up the cloud-init netplan file:

```bash
# Back up the cloud-init netplan file
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/00-installer-config.yaml
```

??? example "Expected result"
    ```bash
    No output.
    ```

Adjust the contents of the file to match this, be careful to double check the name of your network interface, it may vary:

```bash
# Show the current netplan file
sudo cat /etc/netplan/00-installer-config.yaml
```

??? example "Expected result"
    ```bash
    network:
      version: 2
      ethernets:
        enp1s0:
          renderer: networkd
          addresses:
          - "192.168.100.3/24"
          nameservers:
            addresses:
            - 8.8.8.8
            - 1.1.1.1
          routes:
          - to: "default"
            via: "192.168.100.1"
    ```

Apply the netplan changes:

```bash
# Apply the netplan changes
sudo netplan apply
```

??? example "Expected result"
    ```bash
    No output.
    ```

Verify the DNS resolver configuration:

```bash
# Verify the DNS resolver configuration
resolvectl status
```

??? example "Expected result"
    ```bash
    Global
           Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
    resolv.conf mode: stub

    Link 2 (enp1s0)
        Current Scopes: DNS
             Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
    Current DNS Server: 8.8.8.8
           DNS Servers: 192.168.100.3 8.8.8.8 1.1.1.1
            DNS Domain: maas
    ```


## :material-book-open-page-variant-outline: 2.4 Enable MAAS to Manage Libvirt Virtual Machines

**Description:**

In this exercise, you enable MAAS to manage VMs on the Libvirt vhosts by generating
an ssh key for the maas user and uploading it to the vhosts.


**2.4.1 Enable MAAS to Manage Libvirt Virtual Machines**

Enter the following commands to create an SSH key pair that is used to authenticate 
`MAAS` to `libvirt` running on your host machine:

Create the MAAS root SSH directory:

```bash
# Create the MAAS root SSH directory
sudo mkdir -p /var/snap/maas/current/root/.ssh
```

??? example "Expected result"
    ```bash
    No output.
    ```

Generate the MAAS root SSH key pair:

```bash
# Generate the MAAS root SSH key pair
sudo ssh-keygen -t rsa -N "" -q -f /var/snap/maas/current/root/.ssh/id_rsa
```

??? example "Expected result"
    ```bash
    No output.
    ```

Copy the MAAS root public key to the host machine:

```bash
# Copy the MAAS root public key to the host machine
sudo ssh-copy-id -i /var/snap/maas/current/root/.ssh/id_rsa ubuntu@192.168.100.1
```

??? example "Expected result"
    ```bash
    /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/var/snap/maas/current/root/.ssh/id_rsa.pub"
    /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
    /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
    ubuntu@192.168.100.1's password:

    Number of key(s) added: 1

    Now try logging into the machine, with:   "ssh 'ubuntu@192.168.100.1'"
    and check to make sure that only the key(s) you wanted were added.
    ```

!!! note
    This step installs the MAAS root key, not the `ubuntu` user's own key on the
    MAAS VM. A plain `ssh ubuntu@192.168.100.1` from the `ubuntu` shell on the MAAS
    VM can still prompt for a password. The validated non-interactive path is the
    MAAS/root context, for example `sudo ssh -i /var/snap/maas/current/root/.ssh/id_rsa ubuntu@192.168.100.1`.

If host key verification fails, add the host machine to the MAAS root `known_hosts` file:

```bash
# Add the host machine SSH key to known_hosts
sudo ssh-keyscan -H 192.168.100.1 | sudo tee -a /var/snap/maas/current/root/.ssh/known_hosts >/dev/null
```

??? example "Expected result"
    ```bash
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    ```

If `sudo ssh-copy-id` still reports host key verification failures, add the host machine to root's `known_hosts` file as well:

```bash
# Add the host machine SSH key to root known_hosts
sudo mkdir -p /root/.ssh && sudo ssh-keyscan -H 192.168.100.1 | sudo tee -a /root/.ssh/known_hosts >/dev/null
```

??? example "Expected result"
    ```bash
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    # 192.168.100.1:22 SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.15
    ```

!!! note
    Use the password received via email from the instructor.



## :material-book-open-page-variant-outline: 2.5 Create the Cloud Infrastructure Virtual Machines

**Description:**

In this exercise, you create the infrastructure VMs for the lab environment.

**2.5.1 Create the virtual machine infrastructure**


On your `HOST MACHINE` (NOT the MAAS server) you have the script `~/deploy/create-vms.sh` that automate the VM creation process. Execute the command as follows:

```bash
# Create the virtual machine infrastructure
sudo bash ~/deploy/create-vms.sh
```

??? example "Expected result"
    ```bash
    Formatting '/home/VMs/juju01/juju01d1.img', fmt=raw size=42949672960
    Domain 'os-juju01' defined from /root/os-juju01.xml

    Domain 'os-juju01' marked as autostarted

    Formatting '/home/VMs/compute01/compute01d1.img', fmt=raw size=64424509440
    Formatting '/home/VMs/compute01/compute01d2.img', fmt=raw size=21474836480
    Domain 'os-compute01' defined from /root/os-compute01.xml

    Domain 'os-compute01' marked as autostarted

    Formatting '/home/VMs/compute02/compute02d1.img', fmt=raw size=64424509440
    Formatting '/home/VMs/compute02/compute02d2.img', fmt=raw size=21474836480
    Domain 'os-compute02' defined from /root/os-compute02.xml

    Domain 'os-compute02' marked as autostarted

    Formatting '/home/VMs/compute03/compute03d1.img', fmt=raw size=64424509440
    Formatting '/home/VMs/compute03/compute03d2.img', fmt=raw size=21474836480
    Domain 'os-compute03' defined from /root/os-compute03.xml

    Domain 'os-compute03' marked as autostarted

    Formatting '/home/VMs/compute04/compute04d1.img', fmt=raw size=64424509440
    Formatting '/home/VMs/compute04/compute04d2.img', fmt=raw size=21474836480
    Domain 'os-compute04' defined from /root/os-compute04.xml

    Domain 'os-compute04' marked as autostarted
    ```


## :material-book-open-page-variant-outline: 2.6 Enlist and Commission Virtual Machines with MAAS


**Description:**

In this exercise, you enlist and commission the virtual machines in the lab
environment with MAAS.


**2.6.1 Disable running smartctl tests**

You need to disable running `smartctl` tests upon provisioning of the LAB environment.

**Note:** This is only needed in the lab environment due to running it in virtual machines.
In a real production environment it is advised to leave these tests enabled.


Go back to the MAAS server:

```bash
# Go back to the MAAS server
ssh 192.168.100.3
```

??? example "Expected result"
    ```bash
    ubuntu@maas:~$
    ```

In the terminal of the MAAS server, while logged in as the `ubuntu` user,
enter the following commands:

Retrieve the `smartctl-validate` script ID:

```bash
# Retrieve the smartctl-validate script ID
SCRIPT_ID=`maas myprofile node-scripts read | jq '.[] | select(.name=="smartctl-validate") | .id'`
```

??? example "Expected result"
    ```bash
    No output.
    ```

Retag the script so it runs only for storage nodes:

```bash
# Retag the script so it runs only for storage nodes
maas myprofile node-script update $SCRIPT_ID tags=storage
```

??? example "Expected result"
    ```bash
    {
        "name": "smartctl-validate",
        "title": "Storage status",
        "description": "Validate SMART health for all drives in parallel.",
        "tags": [
            "storage"
        ],
        "hardware_type": 3,
        "parallel": 1,
        "results": {},
        "parameters": {
            "storage": {
                "type": "storage",
                "argument_format": "{path}"
            }
        },
        "packages": {
            "apt": [
                "smartmontools"
            ]
        },
        "timeout": "0:05:00",
        "destructive": false,
        "default": true,
        "for_hardware": [],
        "may_reboot": false,
        "recommission": false,
        "apply_configured_networking": false,
        "hardware_type_name": "Storage",
        "history": [
            {
                "id": 14,
                "comment": "Created by maas-None",
                "created": "Fri, 05 Jun 2026 08:34:23 -0000"
            }
        ],
        "id": 14,
        "type": 2,
        "type_name": "Testing script",
        "parallel_name": "Run along other instances of this script",
        "resource_uri": "/MAAS/api/2.0/scripts/smartctl-validate"
    }
    ```

!!! warning
    Before adding the chassis, downgrade the `core22` snap to work around
    [LP #2053033](https://bugs.launchpad.net/maas/+bug/2053033).

Refresh the `core22` snap to the required revision:

```bash
# Refresh the core22 snap to the required revision
sudo snap refresh core22 --channel=latest/stable --revision=1033
```

??? example "Expected result"
    ```bash
    core22 20231123 from Canonical** refreshed
    ```

Restart the MAAS supervisor:

```bash
# Restart the MAAS supervisor
sudo snap restart maas.supervisor
```

??? example "Expected result"
    ```bash
    2026-06-05T11:26:08Z INFO Waiting for "snap.maas.supervisor.service" to stop.
    Restarted.
    ```

**2.6.2 Enlist the Virtual Machines**

In the terminal of the MAAS server, while logged in as the `ubuntu` user,
enter the following command to enlist all virtual machines starting with a
VM name of “os-”:

```bash
# VM name of “os-”
maas myprofile machines add-chassis chassis_type=virsh \
  hostname=qemu+ssh://ubuntu@192.168.100.1/system \
  prefix_filter="os-"
```

??? example "Expected result"
    ```bash
    Asking maas to add machines from chassis qemu+ssh://ubuntu@192.168.100.1/system
    ```

**2.6.3 Commission the Virtual Machines**

In the terminal of the MAAS server, while logged in as the `ubuntu`, enter the following command to commission all virtual machines that are in the ``New`` state:

```bash
# Commission all newly enlisted machines
maas myprofile machines accept-all
```

??? example "Expected result"
    ```bash
    [
        {
            "description": "",
            "architecture": "amd64/generic",
            "status_action": "",
            "address_ttl": null,
            "cpu_speed": 0,
            "workload_annotations": {},
            "owner": "admin",
            "interface_test_status": -1,
            "locked": false,
            "node_type_name": "Machine",
            "storage": 0.0,
            "fqdn": "os-compute02.maas",
            "boot_interface": {
                "mac_address": "52:54:00:63:ae:ac",
                "name": "eth0",
                "system_id": "8dgry3",
                "vlan": null,
                "link_connected": true,
                "children": [],
                "links": [],
                "numa_node": 0,
                "sriov_max_vf": 0,
                "firmware_version": null,
                "parents": [],
                "effective_mtu": 1500,
                "params": {},
                "link_speed": 0,
                "id": 4,
                "product": null,
                "discovered": null,
                "vendor": null,
                "type": "physical",
                "enabled": true,
                "tags": [],
                "interface_speed": 0,
                "resource_uri": "/MAAS/api/2.0/nodes/8dgry3/interfaces/4/"
            },
            "tag_names": [],
            "memory_test_status_name": "Unknown",
            "next_sync": null,
            "ip_addresses": [],
            "testing_status_name": "Unknown",
            "pool": {
                "name": "default",
                "description": "Default pool",
                "id": 0,
                "resource_uri": "/MAAS/api/2.0/resourcepool/0/"
            },
            "osystem": "",
            "raids": [],
            "boot_disk": null,
            "enable_hw_sync": false,
            "current_testing_result_id": null,
            "status_message": "Commissioning",
            "cpu_count": 0,
            "volume_groups": [],
            "current_commissioning_result_id": 2,
            "sync_interval": null,
            "zone": {
                "name": "default",
                "description": "",
                "id": 1,
                "resource_uri": "/MAAS/api/2.0/zones/default/"
            },
            "cpu_test_status": -1,
            "network_test_status": -1,
            "disable_ipv4": false,
            "numanode_set": [
                {
                    "index": 0,
                    "memory": 0,
                    "cores": [],
                    "hugepages_set": []
                }
            ],
            "swap_size": null,
            "network_test_status_name": "Unknown",
            "commissioning_status": 0,
            "blockdevice_set": [],
            "memory_test_status": -1,
            "owner_data": {},
            "system_id": "8dgry3",
            "node_type": 0,
            "current_installation_result_id": null,
            "hardware_info": {
                "system_vendor": "Unknown",
                "system_product": "Unknown",
                "system_family": "Unknown",
                "system_version": "Unknown",
                "system_sku": "Unknown",
                "system_serial": "Unknown",
                "cpu_model": "Unknown",
                "mainboard_vendor": "Unknown",
                "mainboard_product": "Unknown",
                "mainboard_serial": "Unknown",
                "mainboard_version": "Unknown",
                "mainboard_firmware_vendor": "Unknown",
                "mainboard_firmware_date": "Unknown",
                "mainboard_firmware_version": "Unknown",
                "chassis_vendor": "Unknown",
                "chassis_type": "Unknown",
                "chassis_serial": "Unknown",
                "chassis_version": "Unknown"
            },
            "status_name": "Commissioning",
            "parent": null,
            "testing_status": -1,
            "storage_test_status": -1,
            "netboot": true,
            "bios_boot_method": null,
            "storage_test_status_name": "Unknown",
            "special_filesystems": [],
            "commissioning_status_name": "Pending",
            "interface_test_status_name": "Unknown",
            "last_sync": null,
            "cache_sets": [],
            "status": 1,
            "other_test_status": -1,
            "min_hwe_kernel": "",
            "hardware_uuid": null,
            "hostname": "os-compute02",
            "power_type": "virsh",
            "domain": {
                "authoritative": true,
                "ttl": null,
                "is_default": true,
                "resource_record_count": 0,
                "id": 0,
                "name": "maas",
                "resource_uri": "/MAAS/api/2.0/domains/0/"
            },
            "hwe_kernel": null,
            "physicalblockdevice_set": [],
            "cpu_test_status_name": "Unknown",
            "virtualmachine_id": null,
            "other_test_status_name": "Unknown",
            "power_state": "off",
            "interface_set": [
                {
                    "mac_address": "52:54:00:63:ae:ac",
                    "name": "eth0",
                    "system_id": "8dgry3",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 4,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/8dgry3/interfaces/4/"
                },
                {
                    "mac_address": "52:54:00:63:ae:ad",
                    "name": "eth1",
                    "system_id": "8dgry3",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 5,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/8dgry3/interfaces/5/"
                }
            ],
            "ephemeral_deploy": false,
            "bcaches": [],
            "pod": null,
            "default_gateways": {
                "ipv4": {
                    "gateway_ip": null,
                    "link_id": null
                },
                "ipv6": {
                    "gateway_ip": null,
                    "link_id": null
                }
            },
            "virtualblockdevice_set": [],
            "distro_series": "",
            "memory": 0,
            "resource_uri": "/MAAS/api/2.0/machines/8dgry3/"
        },
        {
            "description": "",
            "architecture": "amd64/generic",
            "status_action": "",
            "address_ttl": null,
            "cpu_speed": 0,
            "workload_annotations": {},
            "owner": "admin",
            "interface_test_status": -1,
            "locked": false,
            "node_type_name": "Machine",
            "storage": 0.0,
            "fqdn": "os-compute01.maas",
            "boot_interface": {
                "mac_address": "52:54:00:63:0e:0c",
                "name": "eth0",
                "system_id": "gedepf",
                "vlan": null,
                "link_connected": true,
                "children": [],
                "links": [],
                "numa_node": 0,
                "sriov_max_vf": 0,
                "firmware_version": null,
                "parents": [],
                "effective_mtu": 1500,
                "params": {},
                "link_speed": 0,
                "id": 2,
                "product": null,
                "discovered": null,
                "vendor": null,
                "type": "physical",
                "enabled": true,
                "tags": [],
                "interface_speed": 0,
                "resource_uri": "/MAAS/api/2.0/nodes/gedepf/interfaces/2/"
            },
            "tag_names": [],
            "memory_test_status_name": "Unknown",
            "next_sync": null,
            "ip_addresses": [],
            "testing_status_name": "Unknown",
            "pool": {
                "name": "default",
                "description": "Default pool",
                "id": 0,
                "resource_uri": "/MAAS/api/2.0/resourcepool/0/"
            },
            "osystem": "",
            "raids": [],
            "boot_disk": null,
            "enable_hw_sync": false,
            "current_testing_result_id": null,
            "status_message": "Commissioning",
            "cpu_count": 0,
            "volume_groups": [],
            "current_commissioning_result_id": 4,
            "sync_interval": null,
            "zone": {
                "name": "default",
                "description": "",
                "id": 1,
                "resource_uri": "/MAAS/api/2.0/zones/default/"
            },
            "cpu_test_status": -1,
            "network_test_status": -1,
            "disable_ipv4": false,
            "numanode_set": [
                {
                    "index": 0,
                    "memory": 0,
                    "cores": [],
                    "hugepages_set": []
                }
            ],
            "swap_size": null,
            "network_test_status_name": "Unknown",
            "commissioning_status": 0,
            "blockdevice_set": [],
            "memory_test_status": -1,
            "owner_data": {},
            "system_id": "gedepf",
            "node_type": 0,
            "current_installation_result_id": null,
            "hardware_info": {
                "system_vendor": "Unknown",
                "system_product": "Unknown",
                "system_family": "Unknown",
                "system_version": "Unknown",
                "system_sku": "Unknown",
                "system_serial": "Unknown",
                "cpu_model": "Unknown",
                "mainboard_vendor": "Unknown",
                "mainboard_product": "Unknown",
                "mainboard_serial": "Unknown",
                "mainboard_version": "Unknown",
                "mainboard_firmware_vendor": "Unknown",
                "mainboard_firmware_date": "Unknown",
                "mainboard_firmware_version": "Unknown",
                "chassis_vendor": "Unknown",
                "chassis_type": "Unknown",
                "chassis_serial": "Unknown",
                "chassis_version": "Unknown"
            },
            "status_name": "Commissioning",
            "parent": null,
            "testing_status": -1,
            "storage_test_status": -1,
            "netboot": true,
            "bios_boot_method": null,
            "storage_test_status_name": "Unknown",
            "special_filesystems": [],
            "commissioning_status_name": "Pending",
            "interface_test_status_name": "Unknown",
            "last_sync": null,
            "cache_sets": [],
            "status": 1,
            "other_test_status": -1,
            "min_hwe_kernel": "",
            "hardware_uuid": null,
            "hostname": "os-compute01",
            "power_type": "virsh",
            "domain": {
                "authoritative": true,
                "ttl": null,
                "is_default": true,
                "resource_record_count": 0,
                "id": 0,
                "name": "maas",
                "resource_uri": "/MAAS/api/2.0/domains/0/"
            },
            "hwe_kernel": null,
            "physicalblockdevice_set": [],
            "cpu_test_status_name": "Unknown",
            "virtualmachine_id": null,
            "other_test_status_name": "Unknown",
            "power_state": "off",
            "interface_set": [
                {
                    "mac_address": "52:54:00:63:0e:0c",
                    "name": "eth0",
                    "system_id": "gedepf",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 2,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/gedepf/interfaces/2/"
                },
                {
                    "mac_address": "52:54:00:63:0e:0d",
                    "name": "eth1",
                    "system_id": "gedepf",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 3,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/gedepf/interfaces/3/"
                }
            ],
            "ephemeral_deploy": false,
            "bcaches": [],
            "pod": null,
            "default_gateways": {
                "ipv4": {
                    "gateway_ip": null,
                    "link_id": null
                },
                "ipv6": {
                    "gateway_ip": null,
                    "link_id": null
                }
            },
            "virtualblockdevice_set": [],
            "distro_series": "",
            "memory": 0,
            "resource_uri": "/MAAS/api/2.0/machines/gedepf/"
        },
        {
            "description": "",
            "architecture": "amd64/generic",
            "status_action": "",
            "address_ttl": null,
            "cpu_speed": 0,
            "workload_annotations": {},
            "owner": "admin",
            "interface_test_status": -1,
            "locked": false,
            "node_type_name": "Machine",
            "storage": 0.0,
            "fqdn": "os-juju01.maas",
            "boot_interface": {
                "mac_address": "52:54:00:63:6e:6a",
                "name": "eth0",
                "system_id": "hyedet",
                "vlan": null,
                "link_connected": true,
                "children": [],
                "links": [],
                "numa_node": 0,
                "sriov_max_vf": 0,
                "firmware_version": null,
                "parents": [],
                "effective_mtu": 1500,
                "params": {},
                "link_speed": 0,
                "id": 10,
                "product": null,
                "discovered": null,
                "vendor": null,
                "type": "physical",
                "enabled": true,
                "tags": [],
                "interface_speed": 0,
                "resource_uri": "/MAAS/api/2.0/nodes/hyedet/interfaces/10/"
            },
            "tag_names": [],
            "memory_test_status_name": "Unknown",
            "next_sync": null,
            "ip_addresses": [],
            "testing_status_name": "Unknown",
            "pool": {
                "name": "default",
                "description": "Default pool",
                "id": 0,
                "resource_uri": "/MAAS/api/2.0/resourcepool/0/"
            },
            "osystem": "",
            "raids": [],
            "boot_disk": null,
            "enable_hw_sync": false,
            "current_testing_result_id": null,
            "status_message": "Commissioning",
            "cpu_count": 0,
            "volume_groups": [],
            "current_commissioning_result_id": 6,
            "sync_interval": null,
            "zone": {
                "name": "default",
                "description": "",
                "id": 1,
                "resource_uri": "/MAAS/api/2.0/zones/default/"
            },
            "cpu_test_status": -1,
            "network_test_status": -1,
            "disable_ipv4": false,
            "numanode_set": [
                {
                    "index": 0,
                    "memory": 0,
                    "cores": [],
                    "hugepages_set": []
                }
            ],
            "swap_size": null,
            "network_test_status_name": "Unknown",
            "commissioning_status": 0,
            "blockdevice_set": [],
            "memory_test_status": -1,
            "owner_data": {},
            "system_id": "hyedet",
            "node_type": 0,
            "current_installation_result_id": null,
            "hardware_info": {
                "system_vendor": "Unknown",
                "system_product": "Unknown",
                "system_family": "Unknown",
                "system_version": "Unknown",
                "system_sku": "Unknown",
                "system_serial": "Unknown",
                "cpu_model": "Unknown",
                "mainboard_vendor": "Unknown",
                "mainboard_product": "Unknown",
                "mainboard_serial": "Unknown",
                "mainboard_version": "Unknown",
                "mainboard_firmware_vendor": "Unknown",
                "mainboard_firmware_date": "Unknown",
                "mainboard_firmware_version": "Unknown",
                "chassis_vendor": "Unknown",
                "chassis_type": "Unknown",
                "chassis_serial": "Unknown",
                "chassis_version": "Unknown"
            },
            "status_name": "Commissioning",
            "parent": null,
            "testing_status": -1,
            "storage_test_status": -1,
            "netboot": true,
            "bios_boot_method": null,
            "storage_test_status_name": "Unknown",
            "special_filesystems": [],
            "commissioning_status_name": "Pending",
            "interface_test_status_name": "Unknown",
            "last_sync": null,
            "cache_sets": [],
            "status": 1,
            "other_test_status": -1,
            "min_hwe_kernel": "",
            "hardware_uuid": null,
            "hostname": "os-juju01",
            "power_type": "virsh",
            "domain": {
                "authoritative": true,
                "ttl": null,
                "is_default": true,
                "resource_record_count": 0,
                "id": 0,
                "name": "maas",
                "resource_uri": "/MAAS/api/2.0/domains/0/"
            },
            "hwe_kernel": null,
            "physicalblockdevice_set": [],
            "cpu_test_status_name": "Unknown",
            "virtualmachine_id": null,
            "other_test_status_name": "Unknown",
            "power_state": "off",
            "interface_set": [
                {
                    "mac_address": "52:54:00:63:6e:6a",
                    "name": "eth0",
                    "system_id": "hyedet",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 10,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/hyedet/interfaces/10/"
                },
                {
                    "mac_address": "52:54:00:63:6e:6b",
                    "name": "eth1",
                    "system_id": "hyedet",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 11,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/hyedet/interfaces/11/"
                }
            ],
            "ephemeral_deploy": false,
            "bcaches": [],
            "pod": null,
            "default_gateways": {
                "ipv4": {
                    "gateway_ip": null,
                    "link_id": null
                },
                "ipv6": {
                    "gateway_ip": null,
                    "link_id": null
                }
            },
            "virtualblockdevice_set": [],
            "distro_series": "",
            "memory": 0,
            "resource_uri": "/MAAS/api/2.0/machines/hyedet/"
        },
        {
            "description": "",
            "architecture": "amd64/generic",
            "status_action": "",
            "address_ttl": null,
            "cpu_speed": 0,
            "workload_annotations": {},
            "owner": "admin",
            "interface_test_status": -1,
            "locked": false,
            "node_type_name": "Machine",
            "storage": 0.0,
            "fqdn": "os-compute04.maas",
            "boot_interface": {
                "mac_address": "52:54:00:63:ce:cc",
                "name": "eth0",
                "system_id": "yasrn7",
                "vlan": null,
                "link_connected": true,
                "children": [],
                "links": [],
                "numa_node": 0,
                "sriov_max_vf": 0,
                "firmware_version": null,
                "parents": [],
                "effective_mtu": 1500,
                "params": {},
                "link_speed": 0,
                "id": 8,
                "product": null,
                "discovered": null,
                "vendor": null,
                "type": "physical",
                "enabled": true,
                "tags": [],
                "interface_speed": 0,
                "resource_uri": "/MAAS/api/2.0/nodes/yasrn7/interfaces/8/"
            },
            "tag_names": [],
            "memory_test_status_name": "Unknown",
            "next_sync": null,
            "ip_addresses": [],
            "testing_status_name": "Unknown",
            "pool": {
                "name": "default",
                "description": "Default pool",
                "id": 0,
                "resource_uri": "/MAAS/api/2.0/resourcepool/0/"
            },
            "osystem": "",
            "raids": [],
            "boot_disk": null,
            "enable_hw_sync": false,
            "current_testing_result_id": null,
            "status_message": "Commissioning",
            "cpu_count": 0,
            "volume_groups": [],
            "current_commissioning_result_id": 8,
            "sync_interval": null,
            "zone": {
                "name": "default",
                "description": "",
                "id": 1,
                "resource_uri": "/MAAS/api/2.0/zones/default/"
            },
            "cpu_test_status": -1,
            "network_test_status": -1,
            "disable_ipv4": false,
            "numanode_set": [
                {
                    "index": 0,
                    "memory": 0,
                    "cores": [],
                    "hugepages_set": []
                }
            ],
            "swap_size": null,
            "network_test_status_name": "Unknown",
            "commissioning_status": 0,
            "blockdevice_set": [],
            "memory_test_status": -1,
            "owner_data": {},
            "system_id": "yasrn7",
            "node_type": 0,
            "current_installation_result_id": null,
            "hardware_info": {
                "system_vendor": "Unknown",
                "system_product": "Unknown",
                "system_family": "Unknown",
                "system_version": "Unknown",
                "system_sku": "Unknown",
                "system_serial": "Unknown",
                "cpu_model": "Unknown",
                "mainboard_vendor": "Unknown",
                "mainboard_product": "Unknown",
                "mainboard_serial": "Unknown",
                "mainboard_version": "Unknown",
                "mainboard_firmware_vendor": "Unknown",
                "mainboard_firmware_date": "Unknown",
                "mainboard_firmware_version": "Unknown",
                "chassis_vendor": "Unknown",
                "chassis_type": "Unknown",
                "chassis_serial": "Unknown",
                "chassis_version": "Unknown"
            },
            "status_name": "Commissioning",
            "parent": null,
            "testing_status": -1,
            "storage_test_status": -1,
            "netboot": true,
            "bios_boot_method": null,
            "storage_test_status_name": "Unknown",
            "special_filesystems": [],
            "commissioning_status_name": "Pending",
            "interface_test_status_name": "Unknown",
            "last_sync": null,
            "cache_sets": [],
            "status": 1,
            "other_test_status": -1,
            "min_hwe_kernel": "",
            "hardware_uuid": null,
            "hostname": "os-compute04",
            "power_type": "virsh",
            "domain": {
                "authoritative": true,
                "ttl": null,
                "is_default": true,
                "resource_record_count": 0,
                "id": 0,
                "name": "maas",
                "resource_uri": "/MAAS/api/2.0/domains/0/"
            },
            "hwe_kernel": null,
            "physicalblockdevice_set": [],
            "cpu_test_status_name": "Unknown",
            "virtualmachine_id": null,
            "other_test_status_name": "Unknown",
            "power_state": "off",
            "interface_set": [
                {
                    "mac_address": "52:54:00:63:ce:cc",
                    "name": "eth0",
                    "system_id": "yasrn7",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 8,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/yasrn7/interfaces/8/"
                },
                {
                    "mac_address": "52:54:00:63:ce:cd",
                    "name": "eth1",
                    "system_id": "yasrn7",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 9,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/yasrn7/interfaces/9/"
                }
            ],
            "ephemeral_deploy": false,
            "bcaches": [],
            "pod": null,
            "default_gateways": {
                "ipv4": {
                    "gateway_ip": null,
                    "link_id": null
                },
                "ipv6": {
                    "gateway_ip": null,
                    "link_id": null
                }
            },
            "virtualblockdevice_set": [],
            "distro_series": "",
            "memory": 0,
            "resource_uri": "/MAAS/api/2.0/machines/yasrn7/"
        },
        {
            "description": "",
            "architecture": "amd64/generic",
            "status_action": "",
            "address_ttl": null,
            "cpu_speed": 0,
            "workload_annotations": {},
            "owner": "admin",
            "interface_test_status": -1,
            "locked": false,
            "node_type_name": "Machine",
            "storage": 0.0,
            "fqdn": "os-compute03.maas",
            "boot_interface": {
                "mac_address": "52:54:00:63:be:bc",
                "name": "eth0",
                "system_id": "achkf6",
                "vlan": null,
                "link_connected": true,
                "children": [],
                "links": [],
                "numa_node": 0,
                "sriov_max_vf": 0,
                "firmware_version": null,
                "parents": [],
                "effective_mtu": 1500,
                "params": {},
                "link_speed": 0,
                "id": 6,
                "product": null,
                "discovered": null,
                "vendor": null,
                "type": "physical",
                "enabled": true,
                "tags": [],
                "interface_speed": 0,
                "resource_uri": "/MAAS/api/2.0/nodes/achkf6/interfaces/6/"
            },
            "tag_names": [],
            "memory_test_status_name": "Unknown",
            "next_sync": null,
            "ip_addresses": [],
            "testing_status_name": "Unknown",
            "pool": {
                "name": "default",
                "description": "Default pool",
                "id": 0,
                "resource_uri": "/MAAS/api/2.0/resourcepool/0/"
            },
            "osystem": "",
            "raids": [],
            "boot_disk": null,
            "enable_hw_sync": false,
            "current_testing_result_id": null,
            "status_message": "Commissioning",
            "cpu_count": 0,
            "volume_groups": [],
            "current_commissioning_result_id": 10,
            "sync_interval": null,
            "zone": {
                "name": "default",
                "description": "",
                "id": 1,
                "resource_uri": "/MAAS/api/2.0/zones/default/"
            },
            "cpu_test_status": -1,
            "network_test_status": -1,
            "disable_ipv4": false,
            "numanode_set": [
                {
                    "index": 0,
                    "memory": 0,
                    "cores": [],
                    "hugepages_set": []
                }
            ],
            "swap_size": null,
            "network_test_status_name": "Unknown",
            "commissioning_status": 0,
            "blockdevice_set": [],
            "memory_test_status": -1,
            "owner_data": {},
            "system_id": "achkf6",
            "node_type": 0,
            "current_installation_result_id": null,
            "hardware_info": {
                "system_vendor": "Unknown",
                "system_product": "Unknown",
                "system_family": "Unknown",
                "system_version": "Unknown",
                "system_sku": "Unknown",
                "system_serial": "Unknown",
                "cpu_model": "Unknown",
                "mainboard_vendor": "Unknown",
                "mainboard_product": "Unknown",
                "mainboard_serial": "Unknown",
                "mainboard_version": "Unknown",
                "mainboard_firmware_vendor": "Unknown",
                "mainboard_firmware_date": "Unknown",
                "mainboard_firmware_version": "Unknown",
                "chassis_vendor": "Unknown",
                "chassis_type": "Unknown",
                "chassis_serial": "Unknown",
                "chassis_version": "Unknown"
            },
            "status_name": "Commissioning",
            "parent": null,
            "testing_status": -1,
            "storage_test_status": -1,
            "netboot": true,
            "bios_boot_method": null,
            "storage_test_status_name": "Unknown",
            "special_filesystems": [],
            "commissioning_status_name": "Pending",
            "interface_test_status_name": "Unknown",
            "last_sync": null,
            "cache_sets": [],
            "status": 1,
            "other_test_status": -1,
            "min_hwe_kernel": "",
            "hardware_uuid": null,
            "hostname": "os-compute03",
            "power_type": "virsh",
            "domain": {
                "authoritative": true,
                "ttl": null,
                "is_default": true,
                "resource_record_count": 0,
                "id": 0,
                "name": "maas",
                "resource_uri": "/MAAS/api/2.0/domains/0/"
            },
            "hwe_kernel": null,
            "physicalblockdevice_set": [],
            "cpu_test_status_name": "Unknown",
            "virtualmachine_id": null,
            "other_test_status_name": "Unknown",
            "power_state": "off",
            "interface_set": [
                {
                    "mac_address": "52:54:00:63:be:bc",
                    "name": "eth0",
                    "system_id": "achkf6",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 6,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/achkf6/interfaces/6/"
                },
                {
                    "mac_address": "52:54:00:63:be:bd",
                    "name": "eth1",
                    "system_id": "achkf6",
                    "vlan": null,
                    "link_connected": true,
                    "children": [],
                    "links": [],
                    "numa_node": 0,
                    "sriov_max_vf": 0,
                    "firmware_version": null,
                    "parents": [],
                    "effective_mtu": 1500,
                    "params": {},
                    "link_speed": 0,
                    "id": 7,
                    "product": null,
                    "discovered": null,
                    "vendor": null,
                    "type": "physical",
                    "enabled": true,
                    "tags": [],
                    "interface_speed": 0,
                    "resource_uri": "/MAAS/api/2.0/nodes/achkf6/interfaces/7/"
                }
            ],
            "ephemeral_deploy": false,
            "bcaches": [],
            "pod": null,
            "default_gateways": {
                "ipv4": {
                    "gateway_ip": null,
                    "link_id": null
                },
                "ipv6": {
                    "gateway_ip": null,
                    "link_id": null
                }
            },
            "virtualblockdevice_set": [],
            "distro_series": "",
            "memory": 0,
            "resource_uri": "/MAAS/api/2.0/machines/achkf6/"
        }
    ]
    ```


**2.6.4 Performance tune the LAB environment**

In this task you will perform some LAB specific tasks to allow you to successfully
complete the rest of the tasks.

**Note:** It is recommended that you do not perform these steps in a production environment
as doing so might lead to undesired results.

While logged into the MAAS machine as `ubuntu`, execute the following to
disable adding a swap file and generating excessive IO on the host.

Append the swap override to the curtin userdata sample:

```bash
# Append the swap override to the curtin userdata sample
sudo tee -a /var/snap/maas/current/preseeds/curtin_userdata.sample <<EOF
swap:
  size: 0
EOF
```

??? example "Expected result"
    ```bash
    swap:
      size: 0
    ```

Edit the curtin userdata sample and add two spaces before `size`:

```bash
# Edit the curtin userdata sample and add two spaces before size
sudo vim /var/snap/maas/current/preseeds/curtin_userdata.sample
```

??? example "Expected result"
    ```bash
    {
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }
    ```

Configure quick disk erasing. Otherwise, redeploying nodes takes longer
than 40 minutes and thus fail with a timeout. This needs to be done prior to
commissioning of the VMs.

Disable secure erase:

```bash
# Disable secure erase
maas myprofile maas set-config name=disk_erase_with_secure_erase value=false
```

??? example "Expected result"
    ```bash
    OK
    ```

Enable quick erase:

```bash
# Enable quick erase
maas myprofile maas set-config name=disk_erase_with_quick_erase value=true
```

??? example "Expected result"
    ```bash
    OK
    ```

Enable disk erasing on release:

```bash
# Enable disk erasing on release
maas myprofile maas set-config name=enable_disk_erasing_on_release value=true
```

??? example "Expected result"
    ```bash
    OK
    ```


## :material-book-open-page-variant-outline: 2.7 Define Tags for the Cloud Nodes


**Description:**

In this exercise, you view and define tags in the MAAS system.


**2.7.1 List Tags and Systems by Tag**

The listing of existing tags and systems associated with each tag can be accomplished
via the CLI or the WebUI.

In the terminal of the MAAS server, while logged in as the `ubuntu`,
enter the following command to list the existing tags:

```bash
# list the existing tags
maas myprofile tags read
```

??? example "Expected result"
    ```bash
    [
        {
            "name": "virtual",
            "definition": "",
            "comment": "",
            "kernel_opts": "",
            "resource_uri": "/MAAS/api/2.0/tags/virtual/"
        }
    ]
    ```

You should see a list of the existing tags.

Enter the following command to list all of the systems that match the tag `virtual`:

```bash
# list all of the systems that match the tag virtual
maas myprofile tag nodes virtual | grep hostname
```

??? example "Expected result"
    ```bash
            "hostname": "maas",
            "hostname": "os-compute01",
            "hostname": "os-compute02",
            "hostname": "os-compute03",
            "hostname": "os-compute04",
            "hostname": "os-juju01",
    ```

You should see the hostname of all of the nodes that match the tag `virtual`.



**2.7.2 Define New Tags for the Cloud Nodes and Assign Systems to Them**

Defining new tags and assigning systems to them can be accomplished via the CLI or the WebUI.


Enter the following command to create a tag without a definition for the Juju bootstrap node:

```bash
# create a tag without a definition for the Juju bootstrap node
maas myprofile tags create name=juju
```

??? example "Expected result"
    ```bash
    {
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }
    ```

Enter the following command to list details for the Juju bootstrap node:

```bash
# list details for the Juju bootstrap node
maas myprofile machines read hostname=os-juju01
```

??? example "Expected result"
    ```bash
    {
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }
    ```

Retrieve the system ID for the Juju bootstrap node:

```bash
# Retrieve the system ID for the Juju bootstrap node
JUJU01_ID=`maas myprofile machines read hostname=os-juju01 | jq -r ".[].system_id"`
```

??? example "Expected result"
    ```bash
    hyedet
    ```

Associate the system with the `juju` tag:

```bash
# Associate the system with the juju tag
maas myprofile tag update-nodes juju add=$JUJU01_ID
```

??? example "Expected result"
    ```bash
    {
        "added": 1,
        "removed": 0
    }
    ```

Enter the following command to view the system associated the juju tag:

```bash
# view the system associated the juju tag
maas myprofile tag nodes juju | grep hostname
```

??? example "Expected result"
    ```bash
            "hostname": "os-juju01",
    ```

You should see the system you just added the tag to listed.


Enter the following command to create the tag for the os-compute## nodes:

```bash
# create the tag for the os-compute## nodes
maas myprofile tags create name=storage
```

??? example "Expected result"
    ```bash
    {
        "name": "storage",
        "definition": "",
        "comment": "",
        "kernel_opts": "",
        "resource_uri": "/MAAS/api/2.0/tags/storage/"
    }
    ```

Run the following command to associate the `storage` tag to the rest of the VMs:

```bash
# associate the storage tag to the rest of the VMs
for i in `seq 1 4` ; do
  NODE_NAME=os-compute0${i}
  NODE_ID=`maas myprofile machines read hostname=${NODE_NAME} | jq -r ".[].system_id"`
  maas myprofile tag update-nodes storage add=${NODE_ID}
done
```

??? example "Expected result"
    ```bash
    {
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }{
        "added": 1,
        "removed": 0
    }
    ```

Enter the following command to view the systems associated with the storage tag:

```bash
# view the systems associated with the storage tag
maas myprofile tag nodes storage | grep hostname
```

??? example "Expected result"
    ```bash
            "hostname": "os-compute01",
            "hostname": "os-compute02",
            "hostname": "os-compute03",
            "hostname": "os-compute04",
    ```


## :material-book-open-page-variant-outline: 2.8 Web UI Equivalents

This section provides Web UI equivalents for selected CLI tasks from earlier in
the chapter. If you already completed those tasks via the CLI, treat this
section as optional verification or an alternate workflow.

### :material-book-open-page-variant-outline: 2.8.1 Perform Initial Configuration of a MAAS Server

**2.8.1.1 Download the Boot Images**

**To download the boot images via the WebUI perform the following:**

1. Open a web browser and point to: `http://192.168.100.3:5240/MAAS`.
2. Log in as `admin`.
3. Go on the `Images` page.
4. Under `Releases` section select `22.04 LTS`.
5. Under `Architecture` select `amd64`.
6. Click `Update selection`.

**2.8.1.2 Upload SSH Keys for the MAAS Shell Admin User into MAAS**

**To upload the SSH keys into MAAS via the WebUI perform the following:**

1. In the MAAS WebUI, click on `admin` in the bottom left sidebar.
2. In the `SSH Keys` section, click on `Import SSH Key`.
3. As `Source`, select `Upload`.
4. Copy and paste the contents of the `~/.ssh/id_rsa.pub` file into the `Public key` field and then click `Import SSH key`.

### :material-book-open-page-variant-outline: 2.8.2 Configure a MAAS Rack Controller to Manage DHCP

**Description**

In this exercise, you configure a MAAS rack controller to manage DHCP on its
network. You will also reserve two IP address ranges for use external to MAAS.
Finally, you will configure the DNS servers and kernel parameters to be used by
the MAAS server and any nodes it deploys.

**2.8.2.1 Enable DHCP and Reserve IP Ranges**

**To enable DHCP and reserve IP ranges via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
> Log in using the MAAS administrator credentials.
2. Select the `Subnets` menu on the left.
3. On the `Subnets` page, select the `untagged` link under the `VLAN` header.
> You should see the `Default VLAN in Fabric-0` configuration page displayed.
4. In the `DHCP` section, click on `Enable DHCP`.
5. Configure the DHCP range with `192.168.100.200` as the start address and `192.168.100.254` as the end address.
6. Click the `Configure DHCP` button.
7. On the `Subnets` page, scroll down to the `Reserved` section.
8. Click on the `Reserve range` button in the `Reserved` section.
9. Enter `192.168.100.1`, `192.168.100.9`, and `Purpose: static` in their corresponding fields.
10. Click on the `Reserve` button.
11. Click on the `Reserve Range` button again.
12. Enter `192.168.100.150`, `192.168.100.199`, and `Purpose: floating` in their corresponding fields.
13. Click on the `Reserve` button.


**2.8.2.2 Configure Upstream DNS**

Configuring the upstream DNS can be accomplished via the CLI or the WebUI.

**To configure the upstream DNS via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
2. Log in using the MAAS administrator credentials.
3. Go on `Settings` menu on the left sidebar, then `DNS` under the `Network` menu.
4. Under the `DNS` section, in the `Upstream DNS used to resolve domains not managed by this MAAS` field, enter the following value: `8.8.8.8`.
5. Click the `Save` button below the `DNS` section.


**2.8.2.3 Configure Kernel options for nodes**

Configuring the kernel options that will be supplied to nodes can be accomplished
via the CLI or the WebUI.

**To configure the kernel options via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`
2. Log in using the MAAS administrator credentials
3. Go on `Settings` menu on the left sidebar, and under `Configuration` section, you'll see `Kernel parameters` section
4. In the `Global boot parameters always passed to the kernel` field, enter the following value: `net.ifnames=0`
5. Click the `Save` button below.


### :material-book-open-page-variant-outline: 2.8.3 Enlist and Commission Virtual Machines with MAAS

**2.8.3.1 Enlist the Virtual Machines**

**To enlist virtual machines via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
2. Click on the `Machines` on the left sidebar.
3. From the `Add Hardware` drop-down list, select `Chassis`.
4. Under the `Add chassis` section change `Power type` to `Virsh (virtual systems)`.
5. Enter the following values:
> `Address`: `qemu+ssh://ubuntu@192.168.100.1/system`<br/>
6. When finished entering the values, click `Save chassis`.
> After saving the chassis, you will see all of the VMs you previously created appear in the nodes list.


**2.8.3.2 Commission the Virtual Machines**

**To commission virtual machines via the WebUI perform the following:**

1. In the MAAS server web interface, select the `Machines` tab.
2. Tick the `check-box` next to `FQDN` to select all of the nodes.
3. From the `Actions` drop-down list, select `Commission`.
4. Click `Commission nodes`.
> All of the nodes should start powering on. While the nodes are commissioning
> their status should go from  `New` to `Commissioning` Once the commissioning
> is complete, they should power off and their status should change from
> `Commissioning` to `Ready`.


### :material-book-open-page-variant-outline: 2.8.4 Define Tags for the Cloud Nodes


**Description:**

In this exercise, you view and define tags in the MAAS system.


**2.8.4.1 List Tags and Systems by Tag**

**To list the tags and systems via the WebUI perform the following:**

1. Open a web browser and point to: `http://192.168.100.3:5240/MAAS` and log in as `admin`.
2. From the tabs at the top of the screen, click on the `Machines` tab.
3. In the `Filter` drop down box on the left side of the browser window click on the `Tags` link to expand the view. A listing of tags should be displayed.
4. Click on the tag `virtual` to display the systems (in the right pane of the browser window) assigned to the tag `virtual`.


**2.8.4.2 Define New Tags for the Cloud Nodes and Assign Systems to Them**

**To define tags and assign systems via the WebUI perform the following:**

1. In the MAAS WebUI, select the `Machines` left sidebar menu.
2. Click on the `os-juju01` node.
3. In the `Machine summary`, click on the `Tags` field.
4. In the `Tags` section, type `juju` and press `Enter`.
5. Click on `Save changes`.
> You should see the `juju` tag listed in the `Tags` section.
6. For each of the compute nodes, click on the node name and repeat steps 3 through 6, entering `storage` instead of `juju`.
> You should see the `storage` tag listed in the `Machine summary` for each node.
7. Return to the Machines page by clicking the `Machines` tab.
8. Click on the `Tags` link in the `Filter by` pane. You should see the `juju` and `storage` tags in the list.
