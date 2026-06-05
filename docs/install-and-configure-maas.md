# 2. Install and Configure MAAS

**Description:**

In this section, you install and configure a MAAS environment.



## :material-book-open-page-variant-outline: 2.1 Install a MAAS Server


### :material-book-open-page-variant-outline: Task 1: Install MAAS Packages

Generate an SSH key pair:

```bash
ssh-keygen -t rsa -N "" -q -f ~/.ssh/id_rsa
```

??? example "Expected result"
    Pending live validation.

Copy the SSH key to the MAAS server. Use `ubuntu` as the password:

```bash
# password is ubuntu
ssh-copy-id 192.168.100.3
```

??? example "Expected result"
    Pending live validation.

Copy the configuration files and bundles that you use later:

```bash
scp -r /home/ubuntu/os_files 192.168.100.3:~
```

??? example "Expected result"
    Pending live validation.


Log in to the MAAS VM:

```bash
ssh 192.168.100.3
```

??? example "Expected result"
    Pending live validation.

Install the MAAS snap:

```bash
sudo snap install maas --channel=3.4
```

??? example "Expected result"
    Pending live validation.

Install the MAAS test database snap:

```bash
sudo snap install maas-test-db --channel=3.4
```

??? example "Expected result"
    Pending live validation.

Initialize MAAS as a region and rack controller:

```bash
sudo maas init region+rack --database-uri maas-test-db:///
```

??? example "Expected result"
    MAAS URL [default=http://192.168.100.3:5240/MAAS]:
    MAAS has been set up.

    If you want to configure external authentication or use
    MAAS with Canonical RBAC, please run

      sudo maas configauth

    To create admins when not using external authentication, run

      sudo maas createadmin

    To enable TLS for secured communication, please run

      sudo maas config-tls enable

!!! note
    Press `Enter` when asked about the MAAS URL.


## :material-book-open-page-variant-outline: 2.2 Perform Initial Configuration of a MAAS Server


**Description:**

In this exercise, you perform the initial configuration steps of a MAAS server
such as creating the administrator user and downloading the boot images, both focal (20.04) and jammy (22.04).


### :material-book-open-page-variant-outline: Task 1: Create the Administrator User

Enter the following command to create the administrator account, `ubuntu` is the password:

```bash
sudo maas createadmin --username=admin --password=ubuntu --email=admin@example.com
```

??? example "Expected result"
    Pending live validation.


### :material-book-open-page-variant-outline: Task 2: Log into the MAAS server API via the Command Line Interface

In a terminal on the MAAS server, while logged in as the `ubuntu`, enter
the following command to retrieve the API key for the MAAS admin user and save
it to the file ```~/maas-apikey```:

```bash
sudo maas apikey --username=admin > ~/maas-apikey
```

??? example "Expected result"
    Pending live validation.

Enter the following command to log into MAAS and create a profile:

```bash
maas login myprofile http://192.168.100.3:5240/MAAS - < ~/maas-apikey
```

??? example "Expected result"
    Pending live validation.

Verify that you are logged into the MAAS with the profile name of `myprofile`

```bash
maas list
```

??? example "Expected result"
    Pending live validation.


### :material-book-open-page-variant-outline: Task 3: Download the Boot Images

By default, the "focal" (20.04) Ubuntu LTS is marked for download and we need to also download "jammy" (22.04) release, as well. Download the selected boot images:

```bash
maas myprofile boot-source-selections create 1 os="ubuntu" release="jammy" arches="amd64" \
  subarches="*" labels="*"
```

??? example "Expected result"
    Pending live validation.

Start the boot resource import:

```bash
maas myprofile boot-resources import
```

??? example "Expected result"
    Pending live validation.


### :material-book-open-page-variant-outline: Task 4: Generate SSH Keys for the MAAS Shell Admin User

In the terminal on the MAAS server, while logged in as the `ubuntu`,
enter the following command to generate a new SSH key pair:

```bash
ssh-keygen -t rsa -N "" -q -f ~/.ssh/id_rsa
```

??? example "Expected result"
    Pending live validation.


### :material-book-open-page-variant-outline: Task 5: Upload SSH Keys for the MAAS Shell Admin User into MAAS


In the terminal of the MAAS server, while logged in as the `ubuntu`,
enter the following command to upload the SSH key generated in Task 4:

```bash
maas myprofile sshkeys create key="`cat ~/.ssh/id_rsa.pub`"
```

??? example "Expected result"
    Pending live validation.


## :material-book-open-page-variant-outline: 2.3 Configure a MAAS Rack Controller to Manage DHCP


**Description**

In this exercise, you configure a MAAS rack controller to manage DHCP on it's
network. You will also reserve two IP address ranges for use external to MAAS.
Finally, you will configure the DNS servers and kernel parameters to be used by
the MAAS server and any nodes it deploys.


### :material-book-open-page-variant-outline: Task 1: Enable DHCP and Reserve IP Ranges

Enabling DHCP and reserving IP ranges can be accomplished via the CLI or the WebUI.


In the terminal of the MAAS server, while logged in as `ubuntu`:

Retrieve the fabric ID of the first fabric:

```bash
FABRIC_ID=`maas myprofile fabrics read | jq ".[0].id"`
```

??? example "Expected result"
    Pending live validation.

Retrieve the VLAN ID of the first VLAN associated with the fabric ID:

```bash
VLAN_ID=`maas myprofile vlans read $FABRIC_ID | jq ".[0].vid"`
```

??? example "Expected result"
    Pending live validation.

Retrieve the system ID for the primary rack controller:

```bash
RACK_ID=`maas myprofile rack-controllers read | jq -r ".[0].system_id"`
```

??? example "Expected result"
    Pending live validation.

Add the Dynamic IP address range that will be used by MAAS for enlistment and commissioning and enable DHCP:

```bash
maas myprofile ipranges create type=dynamic \
  start_ip=192.168.100.200 end_ip=192.168.100.254
```

??? example "Expected result"
    Pending live validation.

Enable DHCP:

```bash
maas myprofile vlan update $FABRIC_ID $VLAN_ID \
  primary_rack=$RACK_ID dhcp_on=true mtu=1400
```

??? example "Expected result"
    Pending live validation.

Add the static IP address range:

```bash
maas myprofile ipranges create type=reserved \
  start_ip=192.168.100.1 end_ip=192.168.100.9
```

??? example "Expected result"
    Pending live validation.

Add the IP address range that will be used for Floating Ips:

```bash
maas myprofile ipranges create type=reserved \
  start_ip=192.168.100.150 end_ip=192.168.100.199
```

??? example "Expected result"
    Pending live validation.


### :material-book-open-page-variant-outline: Task 2: Configure Upstream DNS

Configuring the upstream DNS can be accomplished via the CLI or the WebUI.


Set the Upstream DNS server with the following command:

```bash
maas myprofile maas set-config name=upstream_dns value="8.8.8.8"
```

??? example "Expected result"
    Pending live validation.

### :material-book-open-page-variant-outline: Task 3: Configure Kernel options for nodes

Configuring the kernel options that will be supplied to nodes can be accomplished
via the CLI or the WebUI.

Set the kernel options server with the following command:

```bash
maas myprofile maas set-config name=kernel_opts value="net.ifnames=0"
```

??? example "Expected result"
    Pending live validation.


### :material-book-open-page-variant-outline: Task 4: Configure Local DNS Resolution

In the terminal of the MAAS server, while logged in as the `ubuntu`, set the DNS and search domain to point to the MAAS server.

Back up the cloud-init netplan file:

```bash
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/00-installer-config.yaml
```

??? example "Expected result"
    Pending live validation.

Adjust the contents of the file to match this, be careful to double check the name of your network interface, it may vary:

```bash
sudo cat /etc/netplan/00-installer-config.yaml
```

??? example "Expected result"
    network:
        ethernets:
            enp1s0:
                addresses:
                - 192.168.100.3/24
                nameservers:
                    addresses:
                    - 192.168.100.3
                    - 8.8.8.8
                    search:
                    - maas
                renderer: networkd
                routes:
                -   to: default
                    via: 192.168.100.1
        version: 2

Apply the netplan changes:

```bash
sudo netplan apply
```

??? example "Expected result"
    Pending live validation.

Verify the DNS resolver configuration:

```bash
resolvectl status
```

??? example "Expected result"
    Pending live validation.


## :material-book-open-page-variant-outline: 2.4 Enable MAAS to Manage Libvirt Virtual Machines

**Description:**

In this exercise, you enable MAAS to manage VMs on the Libvirt vhosts by generating
an ssh key for the maas user and uploading it to the vhosts.


### :material-book-open-page-variant-outline: Task 1: Enable MAAS to Manage Libvirt Virtual Machines

Enter the following commands to create an SSH key pair that is used to authenticate 
`MAAS` to `libvirt` running on your host machine:

Create the MAAS root SSH directory:

```bash
sudo mkdir -p /var/snap/maas/current/root/.ssh
```

??? example "Expected result"
    Pending live validation.

Generate the MAAS root SSH key pair:

```bash
sudo ssh-keygen -t rsa -N "" -q -f /var/snap/maas/current/root/.ssh/id_rsa
```

??? example "Expected result"
    Pending live validation.

Copy the MAAS root public key to the host machine:

```bash
sudo ssh-copy-id -i /var/snap/maas/current/root/.ssh/id_rsa ubuntu@192.168.100.1
```

??? example "Expected result"
    Pending live validation.

Exit the host machine session:

```bash
exit
```

??? example "Expected result"
    Pending live validation.

!!! note
    Use the password received via email from the instructor.



## :material-book-open-page-variant-outline: 2.5 Create the Cloud Infrastructure Virtual Machines

**Description:**

In this exercise, you create the infrastructure VMs for the lab environment.

### :material-book-open-page-variant-outline: Task 1: Create the virtual machine infrastructure


On your `HOST MACHINE` (NOT the MAAS server) you have the script `~/deploy/create-vms.sh` that automate the VM creation process. Execute the command as follows:

```bash
sudo bash ~/deploy/create-vms.sh
```

??? example "Expected result"
    Pending live validation.


## :material-book-open-page-variant-outline: 2.6 Enlist and Commission Virtual Machines with MAAS


**Description:**

In this exercise, you enlist and commission the virtual machines in the lab
environment with MAAS.


### :material-book-open-page-variant-outline: Task 1: Disable running smartctl tests

You need to disable running `smartctl` tests upon provisioning of the LAB environment.

**Note:** This is only needed in the lab environment due to running it in virtual machines.
In a real production environment it is advised to leave these tests enabled.


Go back to the MAAS server:

```bash
ssh 192.168.100.3
```

??? example "Expected result"
    Pending live validation.

In the terminal of the MAAS server, while logged in as the `ubuntu` user,
enter the following commands:

Retrieve the `smartctl-validate` script ID:

```bash
SCRIPT_ID=`maas myprofile node-scripts read | jq '.[] | select(.name=="smartctl-validate") | .id'`
```

??? example "Expected result"
    Pending live validation.

Retag the script so it runs only for storage nodes:

```bash
maas myprofile node-script update $SCRIPT_ID tags=storage
```

??? example "Expected result"
    Pending live validation.

Before adding the chassis, we need to downgrade core22 snap to fix a bug described here: https://bugs.launchpad.net/maas/+bug/2053033

Refresh the `core22` snap to the required revision:

```bash
sudo snap refresh core22 --channel=latest/stable --revision=1033
```

??? example "Expected result"
    Pending live validation.

Restart the MAAS supervisor:

```bash
sudo snap restart maas.supervisor
```

??? example "Expected result"
    Pending live validation.

### :material-book-open-page-variant-outline: Task 2: Enlist the Virtual Machines

In the terminal of the MAAS server, while logged in as the `ubuntu` user,
enter the following command to enlist all virtual machines starting with a
VM name of “os-”:

```bash
maas myprofile machines add-chassis chassis_type=virsh \
  hostname=qemu+ssh://ubuntu@192.168.100.1/system \
  prefix_filter="os-"
```

??? example "Expected result"
    Success.
    Machine-readable output follows:
    Asking maas to add machines from chassis qemu+ssh://ubuntu@192.168.100.1/system

### :material-book-open-page-variant-outline: Task 3: Commission the Virtual Machines

In the terminal of the MAAS server, while logged in as the `ubuntu`, enter the following command to commission all virtual machines that are in the ``New`` state:

```bash
maas myprofile machines accept-all
```

??? example "Expected result"
    Success.
    Machine-readable output follows...


### :material-book-open-page-variant-outline: Task 4: Performance tune the LAB environment

In this task you will perform some LAB specific tasks to allow you to successfully
complete the rest of the tasks.

**Note:** It is recommended that you do not perform these steps in a production environment
as doing so might lead to undesired results.

While logged into the MAAS machine as `ubuntu`, execute the following to
disable adding a swap file and generating excessive IO on the host.

Append the swap override to the curtin userdata sample:

```bash
sudo tee -a /var/snap/maas/current/preseeds/curtin_userdata.sample <<EOF
swap:
  size: 0
EOF
```

??? example "Expected result"
    Pending live validation.

Edit the curtin userdata sample and add two spaces before `size`:

```bash
sudo vim /var/snap/maas/current/preseeds/curtin_userdata.sample
```

??? example "Expected result"
    Pending live validation.

Configure quick disk erasing. Otherwise, redeploying nodes takes longer
than 40 minutes and thus fail with a timeout. This needs to be done prior to
commissioning of the VMs.

Disable secure erase:

```bash
maas myprofile maas set-config name=disk_erase_with_secure_erase value=false
```

??? example "Expected result"
    Pending live validation.

Enable quick erase:

```bash
maas myprofile maas set-config name=disk_erase_with_quick_erase value=true
```

??? example "Expected result"
    Pending live validation.

Enable disk erasing on release:

```bash
maas myprofile maas set-config name=enable_disk_erasing_on_release value=true
```

??? example "Expected result"
    Pending live validation.


## :material-book-open-page-variant-outline: 2.7 Define Tags for the Cloud Nodes


**Description:**

In this exercise, you view and define tags in the MAAS system.


### :material-book-open-page-variant-outline: Task 1: List Tags and Systems by Tag

The listing of existing tags and systems associated with each tag can be accomplished
via the CLI or the WebUI.

In the terminal of the MAAS server, while logged in as the `ubuntu`,
enter the following command to list the existing tags:

```bash
maas myprofile tags read
```

??? example "Expected result"
    Pending live validation.

You should see a list of the existing tags.

Enter the following command to list all of the systems that match the tag `virtual`:

```bash
maas myprofile tag nodes virtual | grep hostname
```

??? example "Expected result"
    Pending live validation.

You should see the hostname of all of the nodes that match the tag `virtual`.



### :material-book-open-page-variant-outline: Task 2: Define New Tags for the Cloud Nodes and Assign Systems to Them

Defining new tags and assigning systems to them can be accomplished via the CLI or the WebUI.


Enter the following command to create a tag without a definition for the Juju bootstrap node:

```bash
maas myprofile tags create name=juju
```

??? example "Expected result"
    Pending live validation.

Enter the following command to list details for the Juju bootstrap node:

```bash
maas myprofile machines read hostname=os-juju01
```

??? example "Expected result"
    Pending live validation.

Retrieve the system ID for the Juju bootstrap node:

```bash
JUJU01_ID=`maas myprofile machines read hostname=os-juju01 | jq -r ".[].system_id"`
```

??? example "Expected result"
    Pending live validation.

Associate the system with the `juju` tag:

```bash
maas myprofile tag update-nodes juju add=$JUJU01_ID
```

??? example "Expected result"
    Pending live validation.

Enter the following command to view the system associated the juju tag:

```bash
maas myprofile tag nodes juju | grep hostname
```

??? example "Expected result"
    Pending live validation.

You should see the system you just added the tag to listed.


Enter the following command to create the tag for the os-compute## nodes:

```bash
maas myprofile tags create name=storage
```

??? example "Expected result"
    Pending live validation.

Run the following command to associate the `storage` tag to the rest of the VMs:

```bash
for i in `seq 1 4` ; do
  NODE_NAME=os-compute0${i}
  NODE_ID=`maas myprofile machines read hostname=${NODE_NAME} | jq -r ".[].system_id"`
  maas myprofile tag update-nodes storage add=${NODE_ID}
done
```

??? example "Expected result"
    Pending live validation.

Enter the following command to view the systems associated with the storage tag:

```bash
maas myprofile tag nodes storage | grep hostname
```

??? example "Expected result"
    "hostname": "os-compute01",
    "hostname": "os-compute02",
    "hostname": "os-compute03",
    "hostname": "os-compute04",


## :material-book-open-page-variant-outline: 2.8 WEB UI

## :material-book-open-page-variant-outline: 2.8.2 Perform Initial Configuration of a MAAS Server

### :material-book-open-page-variant-outline: Task 3: Download the Boot Images

**To download the boot images via the WebUI perform the following:**

1. Open a web browser and point to: `http://192.168.100.3:5240/MAAS`.
2. Log in as `admin`.
3. Go on the `Images` page.
4. Under `Releases` section select `22.04 LTS`.
5. Under `Architecture` select `amd64`.
6. Click `Update selection`.

### :material-book-open-page-variant-outline: Task 5: Upload SSH Keys for the MAAS Shell Admin User into MAAS

**To Upload the SSH keys into MAAS via the WebUI perform the following:**

1. In the MAAS WebUI, click on  `admin` user in the bottom left sidebar.
2. In the  `SSH Keys` section, click on `Import SSH Key`.
3. As `Source`, select `Upload`.
4. Copy and paste the contents of the `~/.ssh/id_rsa.pub` file into the `Public key`.
   field and then click  `Import SSH key`.

## :material-book-open-page-variant-outline: 2.8.3 Configure a MAAS Rack Controller to Manage DHCP

**Description**

In this exercise, you configure a MAAS rack controller to manage DHCP on it's
network. You will also reserve two IP address ranges for use external to MAAS.
Finally, you will configure the DNS servers and kernel parameters to be used by
the MAAS server and any nodes it deploys.

### :material-book-open-page-variant-outline: Task 1: Enable DHCP and Reserve IP Ranges

**To enable DHCP and reserve IP ranges via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
> Log in using the MAAS administrator credentials.
2. Select the `Subnets` menu on the left.
3. On the `Subnets` page, select the `untagged` link under the `VLAN` header.
> You should see the `Default VLAN in Fabric-0` configuration page displayed.
4. In the `DHCP` section, click on `Enable DHCP`.
5. Configure the subnet, `192.168.100.200` and `192.168.100.254` values.
6. Click the `Configure DHCP` button.
7. On the `Subnets` page, scroll down to the `Reserved` section.
8. Click on the `Reserve range` button, `Reserve range` section.
9. Enter the following values in their corresponding fields with `192.168.100.1`, `192.168.100.9` and `Purpose: static` values.
10. Click on the `Reserve` button.
11. Click on the `Reserve Range` button again.
12. Enter the following values in their corresponding fields with `192.168.100.150`, `192.168.100.199` and `Purpose: floating` values.
13. Click on the `Reserve` button.


### :material-book-open-page-variant-outline: Task 2: Configure Upstream DNS

Configuring the upstream DNS can be accomplished via the CLI or the WebUI.

**To configure the upstream DNS via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
2. Log in using the MAAS administrator credentials.
3. Go on `Settings` menu on the left sidebar, then `DNS` under the `Network` menu.
4. Under the `DNS`section, in the `Upstream DNS used to resolve domains not managed by this MAAS` fields, enter the following value: `8.8.8.8`.
5. Click the `Save` button below the `DNS` section.


### :material-book-open-page-variant-outline: Task 3: Configure Kernel options for nodes

Configuring the kernel options that will be supplied to nodes can be accomplished
via the CLI or the WebUI.

**To configure the kernel options via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`
2. Log in using the MAAS administrator credentials
3. Go on `Settings` menu on the left sidebar, and under `Configuration` section, you'll see `Kernel parameters` section
4. In the `Global boot parameters always passed to the kernel` field, enter the following value: `net.ifnames=0`
5. Click the `Save` button below.


## :material-book-open-page-variant-outline: 2.8.4 Enlist and Commission Virtual Machines with MAAS

### :material-book-open-page-variant-outline: Task 2: Enlist the Virtual Machines

**To enlist virtual machines via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
2. Click on the `Machines` on the left sidebar.
3. From the `Add Hardware` drop-down list, select `Chassis`.
4. Under the `Add chassis` section change `Power type` to `Virsh (virtual systems)`.
5. Enter the following values:
> `Address`: `qemu+ssh://ubuntu@192.168.100.1/system`<br/>
6. When finished entering the values, click `Save chassis`.
> After saving the chassis, you will see all of the VMs you previously created appear in the nodes list.


### :material-book-open-page-variant-outline: Task 3: Commission the Virtual Machines

**To commission virtual machines via the WebUI perform the following:**

1. In the MAAS server web interface, select the `Machines` tab.
2. Tick the `check-box` next to `FQDN` to select all of the nodes.
3. From the `Actions` drop-down list, select `Commission`.
4. Click `Commision nodes`.
> All of the nodes should start powering on. While the nodes are commissioning
> their status should go from  `New` to `Commissioning` Once the commissioning
> is complete, they should power off and their status should change from
> `Commissioning` to `Ready`.


## :material-book-open-page-variant-outline: 2.8.5 Define Tags for the Cloud Nodes


**Description:**

In this exercise, you view and define tags in the MAAS system.


### :material-book-open-page-variant-outline: Task 1: List Tags and Systems by Tag

**To list the tags and systems via the WebUI perform the following:**

1. Open a web browser and point to: `http://192.168.100.3:5240/MAAS` and log in as `admin`.
2. From the tabs at the top of the screen, click on the  `Machines` tab.
3. In the `Filter` drop down box on the left side of the browser window click on the `Tags` link to expand the view. A listing of tags should be displayed.
4. Click on the tag `virtual` to display the systems (in the right pane of the browser window) assigned to the tag `virtual`.


### :material-book-open-page-variant-outline: Task 2: Define New Tags for the Cloud Nodes and Assign Systems to Them

**To define tags and assign systems via the WebUI perform the following:**

1. In the MAAS WebUI, select the `Machines` left sidebar menu.
2. Click on the `os-juju01` node.
3. In the `Machine summary`, click on the `Tags` field.
4. In the `Tags` section, type `juju` and press `Enter`.
5. Click on `Save changes`.
> You should see the `juju` tag listed in the `Tags` section.
7. For each of the compute nodes click on the node name and repeat steps 3 though 6 entering  `storage` instead of `juju`.
> You should see the  `storage` tag listed for each node in the `Machine summary`.
8. Return to the Machines page by clicking the `Machines` tab.
9. Click on the `Tags` link in the `Filter by` pane. You should see the `juju` and `storage` tags in the list.
