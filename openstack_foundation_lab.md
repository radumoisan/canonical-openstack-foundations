# Install and Configure a Canonical OpenStack Cloud

**This material is copyright of Canonical Limited. This material may be used for personal and non-commercial use only.**

**This documentation is copyright of Canonical Limited. You are welcome to display on your computer, download and print this documentation or to use the hard copy provided to you for personal, education and non-commercial use only. You must retain copyright, trademark and other notices unaltered on any copies or printouts you make. Any trademarks, logos an service marks displayed in this document are property of their owners, whether Canonical or third parties.**

**This documentation is provided on an "as is" basis, without warranty of any kind, either express or implied. Your use of this documentation is at your own risk. Canonical disclaims all warranties and liability that may result directly or indirectly from the use of this documentation.**

******

# 1 Connect to your Canonical Openstack !heading


The Canonical Openstack will be provided in the cloud. Here it 
is explained how to connect to it.


## 1.1 SSH connection

### Task 1: Create the SSH Tunnel

On `Linux`:

Use the terminal:
```bash
ssh -D 9999 ubuntu@<your public IP>
```

Please note the `-D 9999`. This is a socks proxy. It is used
to access internal UI services of the cloud for, like MAAS and JUJU.


On `Windows` open `Putty`:

1) In the `Session` section, add the `public IP address` you 
received on mail from the trainer, port should be 22.

![ssh](./images/ssh1.png)

2) On the left side, go to `Connection > SSH > Tunnels`

3) In `Source Port` enter `9999`, select `Dynamic` button, 
and click `Add`.

![ssh](./images/ssh2.png)

4) Go back to `Session` section, add a name in `Saved Sessions` and click `Save`.


### Task 2: Set the proxy in browser

Because it's a `SOCKS` proxy, we need to set it in the browser.
`Firefox` will be demonstrated here.


1) Go to `Preferences` or `Options` icon.

2) Navigate to `Network Settings`.

3) Select `Manual proxy configuration`, use `localhost` or
`127.0.0.1` for the `SOCKS host` with port `9999`. Click `OK` when done.

![ssh](./images/ssh3.png)

For `Chrome`, the proxy settings can be configured from the Operating System 
networking configurations,, the proxy settings can be configured from the Operating System 
networking configurations, e.g. LAN Settings on Windows. 


# 2 Install and Configure MAAS !heading

**Description:**

In this section, you install and configure a MAAS environment.



## 2.1 Install a MAAS Server


### Task 1: Install MAAS Packages

Generate an ssh key:

```bash
ssh-keygen -t rsa -N "" -q -f ~/.ssh/id_rsa
```

Copy the ssh key to the MAAS server, with `ubuntu` as password :

```bash
# password is ubuntu
ssh-copy-id 192.168.100.3
```

Copy configuration files and bundles that you are  going to use later:

```bash
scp -r /home/ubuntu/os_files 192.168.100.3:~
```


Login to your MAAS VM and install the MAAS snaps:

```bash
ssh 192.168.100.3
sudo snap install maas --channel=3.4
sudo snap install maas-test-db --channel=3.4
sudo maas init region+rack --database-uri maas-test-db:///
```

> NOTE: press ENTER when asked about the MAAS URL.

Here's the output:

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


## 2.2 Perform Initial Configuration of a MAAS Server


**Description:**

In this exercise, you perform the initial configuration steps of a MAAS server
such as creating the administrator user and downloading the boot images, both focal (20.04) and jammy (22.04).


### Task 1: Create the Administrator User

Enter the following command to create the administrator account, `ubuntu` is the password:

```bash
sudo maas createadmin --username=admin --password=ubuntu --email=admin@example.com
```


### Task 2: Log into the MAAS server API via the Command Line Interface

In a terminal on the MAAS server, while logged in as the `ubuntu`, enter
the following command to retrieve the API key for the MAAS admin user and save
it to the file ```~/maas-apikey```:

```bash
sudo maas apikey --username=admin > ~/maas-apikey
```

Enter the following command to log into MAAS and create a profile:

```bash
maas login myprofile http://192.168.100.3:5240/MAAS - < ~/maas-apikey
```

Verify that you are logged into the MAAS with the profile name of `myprofile`

```bash
maas list
```


### Task 3: Download the Boot Images

By default, the "focal" (20.04) Ubuntu LTS is marked for download and we need to also download "jammy" (22.04) release, as well. Download the selected boot images:

```bash
maas myprofile boot-source-selections create 1 os="ubuntu" release="jammy" arches="amd64" \
  subarches="*" labels="*"
```

```bash
maas myprofile boot-resources import
```


### Task 4: Generate SSH Keys for the MAAS Shell Admin User

In the terminal on the MAAS server, while logged in as the `ubuntu`,
enter the following command to generate a new SSH key pair:

```bash
ssh-keygen -t rsa -N "" -q -f ~/.ssh/id_rsa
```


### Task 5: Upload SSH Keys for the MAAS Shell Admin User into MAAS


In the terminal of the MAAS server, while logged in as the `ubuntu`,
enter the following command to upload the SSH key generated in Task 4:

```bash
maas myprofile sshkeys create key="`cat ~/.ssh/id_rsa.pub`"
```


## 2.3 Configure a MAAS Rack Controller to Manage DHCP


**Description**

In this exercise, you configure a MAAS rack controller to manage DHCP on it's
network. You will also reserve two IP address ranges for use external to MAAS.
Finally, you will configure the DNS servers and kernel parameters to be used by
the MAAS server and any nodes it deploys.


### Task 1: Enable DHCP and Reserve IP Ranges

Enabling DHCP and reserving IP ranges can be accomplished via the CLI or the WebUI.


In the terminal of the MAAS server, while logged in as `ubuntu`:

Retrieve the fabric ID of the first fabric:

```bash
FABRIC_ID=`maas myprofile fabrics read | jq ".[0].id"`
```

Retrieve the VLAN ID of the first VLAN associated with the fabric ID:

```bash
VLAN_ID=`maas myprofile vlans read $FABRIC_ID | jq ".[0].vid"`
```

Retrieve the system ID for the primary rack controller:

```bash
RACK_ID=`maas myprofile rack-controllers read | jq -r ".[0].system_id"`
```

Add the Dynamic IP address range that will be used by MAAS for enlistment and commissioning and enable DHCP:

```bash
maas myprofile ipranges create type=dynamic \
  start_ip=192.168.100.200 end_ip=192.168.100.254
```

Enable DHCP:

```bash
maas myprofile vlan update $FABRIC_ID $VLAN_ID \
  primary_rack=$RACK_ID dhcp_on=true mtu=1400
```

Add the static IP address range:

```bash
maas myprofile ipranges create type=reserved \
  start_ip=192.168.100.1 end_ip=192.168.100.9
```

Add the IP address range that will be used for Floating Ips:

```bash
maas myprofile ipranges create type=reserved \
  start_ip=192.168.100.150 end_ip=192.168.100.199
```


### Task 2: Configure Upstream DNS

Configuring the upstream DNS can be accomplished via the CLI or the WebUI.


Set the Upstream DNS server with the following command:

```bash
maas myprofile maas set-config name=upstream_dns value="8.8.8.8"
```

### Task 3: Configure Kernel options for nodes

Configuring the kernel options that will be supplied to nodes can be accomplished
via the CLI or the WebUI.

Set the kernel options server with the following command:

```bash
maas myprofile maas set-config name=kernel_opts value="net.ifnames=0"
```


### Task 4: Configure Local DNS Resolution

In the terminal of the MAAS server, while logged in as the `ubuntu`, set the DNS and search domain to point to the MAAS server.

```bash
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/00-installer-config.yaml
```

Adjust the contents of the file to match this, be careful to double check the name of your network interface, it may vary:

```bash
sudo cat /etc/netplan/00-installer-config.yaml

# output
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
```

Apply the changes:

```bash
sudo netplan apply
```

and validate the DNS has been updated:

```bash
resolvectl status
```


## 2.4 Enable MAAS to Manage Libvirt Virtual Machines

**Description:**

In this exercise, you enable MAAS to manage VMs on the Libvirt vhosts by generating
an ssh key for the maas user and uploading it to the vhosts.


### Task 1: Enable MAAS to Manage Libvirt Virtual Machines

Enter the following commands to create a SSH key pair that will be used to authenticate 
`MAAS` to `libvirt` running on your host machine:

```bash
sudo mkdir -p /var/snap/maas/current/root/.ssh
```

```bash
sudo ssh-keygen -t rsa -N "" -q -f /var/snap/maas/current/root/.ssh/id_rsa
```

```bash
sudo ssh-copy-id -i /var/snap/maas/current/root/.ssh/id_rsa ubuntu@192.168.100.1

exit
```

> NOTE: at the last step, use the password received via email from the instructor



## 2.5 Create the Cloud Infrastructure Virtual Machines

**Description:**

In this exercise, you create the infrastructure VMs for the lab environment.

### Task 1: Create the virtual machine infrastructure


On your `HOST MACHINE` (NOT the MAAS server) you have the script `~/deploy/create-vms.sh` that automate the VM creation process. Execute the command as follows:

```bash
sudo bash ~/deploy/create-vms.sh
```


## 2.6 Enlist and Commission Virtual Machines with MAAS


**Description:**

In this exercise, you enlist and commission the virtual machines in the lab
environment with MAAS.


### Task 1: Disable running smartctl tests

You need to disable running `smartctl` tests upon provisioning of the LAB environment.

**Note:** This is only needed in the lab environment due to running it in virtual machines.
In a real production environment it is advised to leave these tests enabled.


Go back to the MAAS server:

```bash
ssh 192.168.100.3
```

In the terminal of the MAAS server, while logged in as the `ubuntu` user,
enter the following commands:

```bash
SCRIPT_ID=`maas myprofile node-scripts read | jq '.[] | select(.name=="smartctl-validate") | .id'`
```

```bash
maas myprofile node-script update $SCRIPT_ID tags=storage
```

Before adding the chassis, we need to downgrade core22 snap to fix a bug described here: https://bugs.launchpad.net/maas/+bug/2053033

```bash
sudo snap refresh core22 --channel=latest/stable --revision=1033
sudo snap restart maas.supervisor
```

### Task 2: Enlist the Virtual Machines

In the terminal of the MAAS server, while logged in as the `ubuntu` user,
enter the following command to enlist all virtual machines starting with a
VM name of “os-”:

```bash
maas myprofile machines add-chassis chassis_type=virsh \
  hostname=qemu+ssh://ubuntu@192.168.100.1/system \
  prefix_filter="os-"
```

You should see a message similar to:

```console
Success.
Machine-readable output follows:
Asking maas to add machines from chassis qemu+ssh://ubuntu@192.168.100.1/system
```

### Task 3: Commission the Virtual Machines

In the terminal of the MAAS server, while logged in as the `ubuntu`, enter the following command to commission all virtual machines that are in the ``New`` state:

```bash
maas myprofile machines accept-all
# output
Success.
Machine-readable output follows...
```


### Task 4: Performance tune the LAB environment

In this task you will perform some LAB specific tasks to allow you to successfully
complete the rest of the tasks.

**Note:** It is recommended that you do not perform these steps in a production environment
as doing so might lead to undesired results.

While logged into the MAAS machine as `ubuntu`, execute the following to
disable adding a swap file and generating excessive IO on the host.

```bash
sudo tee -a /var/snap/maas/current/preseeds/curtin_userdata.sample <<EOF
swap:
  size: 0
EOF

# Edit the file and add 2 spaces before "size":
sudo vim /var/snap/maas/current/preseeds/curtin_userdata.sample
```

Configure quick disk erasing, otherwise when redeploying nodes will take longer
than 40 minutes and thus fail with a timeout. This needs to be done prior to
commissioning of the VMs.

```bash
maas myprofile maas set-config name=disk_erase_with_secure_erase value=false
```

```bash
maas myprofile maas set-config name=disk_erase_with_quick_erase value=true
```

```bash
maas myprofile maas set-config name=enable_disk_erasing_on_release value=true
```


## 2.7 Define Tags for the Cloud Nodes


**Description:**

In this exercise, you view and define tags in the MAAS system.


### Task 1: List Tags and Systems by Tag

The listing of existing tags and systems associated with each tag can be accomplished
via the CLI or the WebUI.

In the terminal of the MAAS server, while logged in as the `ubuntu`,
enter the following command to list the existing tags:

```bash
maas myprofile tags read
```

You should see a list of the existing tags.

Enter the following command to list all of the systems that match the tag `virtual`:

```bash
maas myprofile tag nodes virtual | grep hostname
```

You should see the hostname of all of the nodes that match the tag `virtual`.



### Task 2: Define New Tags for the Cloud Nodes and Assign Systems to Them

Defining new tags and assigning systems to them can be accomplished via the CLI or the WebUI.


Enter the following command to create a tag without a definition for the Juju bootstrap node:

```bash
maas myprofile tags create name=juju
```

Enter the following command to list details for the Juju bootstrap node:

```bash
maas myprofile machines read hostname=os-juju01
```

Enter the following command to associate this system with the juju tag:

```bash
JUJU01_ID=`maas myprofile machines read hostname=os-juju01 | jq -r ".[].system_id"`

maas myprofile tag update-nodes juju add=$JUJU01_ID
```

Enter the following command to view the system associated the juju tag:

```bash
maas myprofile tag nodes juju | grep hostname
```

You should see the system you just added the tag to listed.


Enter the following command to create the tag for the os-compute## nodes:

```bash
maas myprofile tags create name=storage
```

Run the following command to associate the `storage` tag to the rest of the VMs:

```bash
for i in `seq 1 4` ; do
  NODE_NAME=os-compute0${i}
  NODE_ID=`maas myprofile machines read hostname=${NODE_NAME} | jq -r ".[].system_id"`
  maas myprofile tag update-nodes storage add=${NODE_ID}
done
```

Enter the following command to view the systems associated with the storage tag:

```bash
maas myprofile tag nodes storage | grep hostname
# output
"hostname": "os-compute01",
"hostname": "os-compute02",
"hostname": "os-compute03",
"hostname": "os-compute04",
```


![maas_nodes](./images/maas_nodes.png)



## 2.8 WEB UI

## 2.8.2 Perform Initial Configuration of a MAAS Server

### Task 3: Download the Boot Images

**To download the boot images via the WebUI perform the following:**

1. Open a web browser and point to: `http://192.168.100.3:5240/MAAS`.
2. Log in as `admin`.
3. Go on the `Images` page.
4. Under `Releases` section select `22.04 LTS`.
5. Under `Architecture` select `amd64`.
6. Click `Update selection`.

### Task 5: Upload SSH Keys for the MAAS Shell Admin User into MAAS

**To Upload the SSH keys into MAAS via the WebUI perform the following:**

1. In the MAAS WebUI, click on  `admin` user in the bottom left sidebar.
2. In the  `SSH Keys` section, click on `Import SSH Key`.
3. As `Source`, select `Upload`.
4. Copy and paste the contents of the `~/.ssh/id_rsa.pub` file into the `Public key`.
   field and then click  `Import SSH key`.

## 2.8.3 Configure a MAAS Rack Controller to Manage DHCP

**Description**

In this exercise, you configure a MAAS rack controller to manage DHCP on it's
network. You will also reserve two IP address ranges for use external to MAAS.
Finally, you will configure the DNS servers and kernel parameters to be used by
the MAAS server and any nodes it deploys.

### Task 1: Enable DHCP and Reserve IP Ranges

**To enable DHCP and reserve IP ranges via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
> Log in using the MAAS administrator credentials.
2. Select the `Subnets` menu on the left.
3. On the `Subnets` page, select the `untagged` link under the `VLAN` header.
> You should see the `Default VLAN in Fabric-0` configuration page displayed.
1. In the `DHCP` section, click on `Enable DHCP`.
2. Configure the subnet, `192.168.100.200` and `192.168.100.254` values.
3. Click the `Configure DHCP` button.
4. On the `Subnets` page, scroll down to the `Reserved` section.
5. Click on the `Reserve range` button, `Reserve range` section.
6. Enter the following values in their corresponding fields with `192.168.100.1`, `192.168.100.9` and `Purpose: static` values.
7. Click on the `Reserve` button.
8. Click on the `Reserve Range` button again.
9. Enter the following values in their corresponding fields with `192.168.100.150`, `192.168.100.199` and `Purpose: floating` values.
10. Click on the `Reserve` button.


### Task 2: Configure Upstream DNS

Configuring the upstream DNS can be accomplished via the CLI or the WebUI.

**To configure the upstream DNS via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
2. Log in using the MAAS administrator credentials.
3. Go on `Settings` menu on the left sidebar, then `DNS` under the `Network` menu.
4. Under the `DNS`section, in the `Upstream DNS used to resolve domains not managed by this MAAS` fields, enter the following value: `8.8.8.8`.
5. Click the `Save` button below the `DNS` section.


### Task 3: Configure Kernel options for nodes

Configuring the kernel options that will be supplied to nodes can be accomplished
via the CLI or the WebUI.

**To configure the kernel options via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`
2. Log in using the MAAS administrator credentials
3. Go on `Settings` menu on the left sidebar, and under `Configuration` section, you'll see `Kernel parameters` section
4. In the `Global boot parameters always passed to the kernel` field, enter the following value: `net.ifnames=0`
5. Click the `Save` button below.


## 2.8.4 Enlist and Commission Virtual Machines with MAAS

### Task 2: Enlist the Virtual Machines

**To enlist virtual machines via the WebUI perform the following:**

1. If not already logged into the MAAS web UI, open a web browser and point to `http://192.168.100.3:5240/MAAS`.
2. Click on the `Machines` on the left sidebar.
3. From the `Add Hardware` drop-down list, select `Chassis`.
4. Under the `Add chassis` section change `Power type` to `Virsh (virtual systems)`.
5. Enter the following values:
> `Address`: `qemu+ssh://ubuntu@192.168.100.1/system`<br/>
6. When finished entering the values, click `Save chassis`.
> After saving the chassis, you will see all of the VMs you previously created appear in the nodes list.


### Task 3: Commission the Virtual Machines

**To commission virtual machines via the WebUI perform the following:**

1. In the MAAS server web interface, select the `Machines` tab.
2. Tick the `check-box` next to `FQDN` to select all of the nodes.
3. From the `Actions` drop-down list, select `Commission`.
4. Click `Commision nodes`.
> All of the nodes should start powering on. While the nodes are commissioning
> their status should go from  `New` to `Commissioning` Once the commissioning
> is complete, they should power off and their status should change from
> `Commissioning` to `Ready`.


## 2.8.5 Define Tags for the Cloud Nodes


**Description:**

In this exercise, you view and define tags in the MAAS system.


### Task 1: List Tags and Systems by Tag

**To list the tags and systems via the WebUI perform the following:**

1. Open a web browser and point to: `http://192.168.100.3:5240/MAAS` and log in as `admin`.
2. From the tabs at the top of the screen, click on the  `Machines` tab.
3. In the `Filter` drop down box on the left side of the browser window click on the `Tags` link to expand the view. A listing of tags should be displayed.
5. Click on the tag `virtual` to display the systems (in the right pane of the browser window) assigned to the tag `virtual`.


### Task 2: Define New Tags for the Cloud Nodes and Assign Systems to Them

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

# 3 Install and Configure Juju !heading

**Description:**

In this section, you install and configure Juju and integrate it with MAAS.

## 3.1 Install the Juju Client


**Description:**

In this exercise, you install Juju on the MAAS server using the recommended way with snaps.

**Note:** You can also use the distribution package of juju, but going forward,
the recommended way to deploy juju is using the `juju snap` from 
the snap store which will always give you the latest stable version 
independent of the underlying operating system version.


### Task 1: Install the Juju Client on the MAAS Server

On the `MAAS server`, open a terminal window and enter the following commands:

```bash
sudo snap install juju --channel=3.6/stable --devmode
```


## 3.2 Bootstrap Juju for MAAS


**Description:**

In this exercise, you will deploy (bootstrap) the Juju state service utilizing MAAS.


### Task 1: Configure Juju for MAAS

**Important:**

When editing a `.yaml` file, spacing and indentation is important. Make sure you use spaces instead of tabs and that you indent new entries to match the other entries in the section you are adding to.

On the MAAS server, enter the following to see the MAAS cloud configuration file for Juju. The ```~/os_files/maas.yaml``` already exists.

```bash
cat ~/os_files/maas.yaml
# output
clouds:
  maas:
    type: maas
    auth-types: [oauth1]
    endpoint: http://192.168.100.3:5240/MAAS/
```

Run the following command to load the MAAS cloud configuration file into Juju:

```bash
juju add-cloud maas ~/os_files/maas.yaml
```

List the clouds available to Juju:

```bash
juju list-clouds
```

Display the contents of the file `~/maas-apikey`:


```bash
cat ~/maas-apikey
```

Create the credentials file Juju will use to authenticate with MAAS:

```bash
juju add-credential maas
```

When prompted by the previous command, enter the following values:
> `credential name`: **admin**
> `Select region`: **Leave blank**
> ``maas-oauth``: **MAAS API key (from step 4)**


Verify the maas-oauth value in `~/.local/share/juju/credentials.yaml` matches the contents of the `~/maas-apikey` file you created earlier. We will call this key **MAAS_API_KEY**.

```bash
cat ~/.local/share/juju/credentials.yaml

cat ~/maas-apikey
```

List all credentials currently configured for Juju:

```bash
juju list-credentials
```

### Task 2: Bootstrap the Juju System

Enter the following command to view the status of Juju:

```bash
juju status
```
> You should get an error because the Juju system has not been bootstrapped.


Enter the following commands to bootstrap Juju:

```bash
juju bootstrap --config default-base="ubuntu@22.04" \
  --bootstrap-constraints="mem=2G cores=1" \
  --constraints="mem=2G tags=juju" \
  maas maas-controller
```

> (this command will take a while to complete because it is installing the OS
> and Juju service on the VM os-juju01)

**Note:** For this command to work, you must have previously created the `juju` tag 
and added the node os-juju01 to the tag. When the command completes, you should 
see an output similar to:

```bash
Creating Juju controller "maas-controller" on maas/default
Looking for packaged Juju agent version 3.6.2 for amd64
Located Juju agent version 3.6.2-ubuntu-amd64 at https://streams.canonical.com/juju/tools/agent/3.6.2/juju-3.6.2-linux-amd64.tgz
Launching controller instance(s) on maas/default...
 - fspqar (arch=amd64 mem=2G cores=2)
Installing Juju agent on bootstrap instance
Waiting for address
Attempting to connect to 192.168.100.10:22
Connected to 192.168.100.10
Running machine configuration script...
Bootstrap agent now started
Contacting Juju controller at 192.168.100.10 to verify accessibility...

Bootstrap complete, controller "maas-controller" is now available
Controller machines are in the "controller" model

Now you can run
	juju add-model <model-name>
to create a new model to deploy workloads.
```

Enter the following command again to view the status of the default model for the MAAS cloud in Juju:

```bash
juju status -m controller
```

>  You should see output showing that the default model for the MAAS cloud is ready. It will look similar to:


```bash
Model       Controller       Cloud/Region  Version  SLA          Timestamp
controller  maas-controller  maas/default  3.6.2    unsupported  13:16:11Z

App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
controller           active      1  juju-controller  3.6/stable  116  no

Unit           Workload  Agent  Machine  Public address  Ports  Message
controller/0*  active    idle   0        192.168.100.10

Machine  State    Address         Inst id    Base          AZ       Message
0        started  192.168.100.10  os-juju01  ubuntu@22.04  default  Deployed
```

![juju-controller](./images/os-cloud-provider4.png)



## 3.3 Access Juju GUI


**Description:**

In this exercise you will use the juju command to deploy the dashboard and then access it.


### Task 1: Deploy Juju Dashboard

1. On the MAAS server, enter the following commands to install and expose Juju Dashboard:

```bash
juju switch controller
juju deploy juju-dashboard dashboard --to=lxd:0
juju integrate dashboard controller
juju expose dashboard
```

2. Wait for the dashboard to be deployed:

```bash
watch -c juju status -m controller --color
```

3. Once dashboard is installed, On MAAS server, run the following command to get the Juju authentication credentials:

```bash
juju dashboard --browser=false
```

Output will be like:

```bash
Dashboard for controller "maas-controller" is enabled at:
  http://localhost:31666
Your login credential is:
  username: admin
  password: 26c3e05096d30b2eff652b1fad5a27a3
```

This command will open a tunnel to your dashboard, but we're not going to use it. Instead, username and password will be useful in this case. 
To get the IP address of your dashboard unit, either Ctrl+C in your current terminal or in a new terminal connected to your MAAS server, run:

```bash
juju show-unit dashboard/0 --format yaml | grep public-address| cut -f 2 -d ":" | awk '{print $1}'
```

4. Open a web browser on the student workstation and point to the address of
   the Juju Dashboard unit with port 8080. E.g. http://192.168.100.11:8080 and use the information provided in the output of the `juju dashboard` command above to log in.


## 3.4 Use juju ssh to Connect to a Node


**Description:**

In this exercise, you use the `juju ssh` and `juju scp` commands to connect to
and copy files to a Juju deployed machine.


### Task 1: List the existing Juju models

In a terminal on the MAAS server enter the following to list the current
models available to the Juju controller:

```bash
juju models
# output
Controller: maas-controller

Model        Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
controller*  maas/default  maas  available         2      2  2      admin   just now
```

### Task 2: Use juju ssh

In a terminal on the MAAS server enter the following command to connect via
SSH to the Juju controller node:

```bash
juju ssh -m controller 0
```

> You should be logged into the node os-juju01.

Enter the following command to disconnect:

```bash
exit
```

> You should be back on the MAAS server.

### Task 3: Use juju scp

Enter the following command to copy a file via scp to the Juju controller node:

```bash
juju scp -m controller /etc/services 0:/tmp
```

Enter the following command to connect via ssh to the Juju controller node:

```bash
juju ssh -m controller 0 -- ls -al /tmp
```
> You should be logged into the node os-juju01 and getting file listing of remote /tmp folder.

> You should see the services file. You can also verify its contents remotely:

```bash
juju ssh -m controller 0 -- cat /tmp/services
```

> You should see the contents of the services file.



# 4 Juju charms !heading

**Description:**

In this section, we will deploy `Landscape Server` application together with all of its dependencies.

## 4.1 Create Model for application deployment

### Task 1: List the existing models associated with the MAAS controller

In a terminal on the MAAS server, as the `ubuntu`, enter the
following to list the current models available to the Juju controller:

```bash
juju models

# output
Controller: maas-controller

Model        Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
controller*  maas/default  maas  available         2      2  2      admin   just now
```

> The model name with the asterisk is the active model for the current (active) controller.


### Task 2: Create a model named landscape

In a terminal on the MAAS server, as the `ubuntu`, enter the following to create the model landscape:

```bash
juju add-model landscape

# output
Added 'landscape' model on maas/default with credential 'admin' for user 'admin'
```

### Task 3: Set the default series for the new model

In a terminal on the MAAS server, as the `ubuntu`,enter the following to set the default base for the model `landscape`:

```bash
juju model-config -m landscape default-base=ubuntu@22.04
```

### Task 4: Verify the new model

In a terminal on the MAAS server, as the `ubuntu`, enter the following to verify the model `landscape` has been created:

```bash
juju models

# output
Controller: maas-controller

Model       Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
controller  maas/default  maas  available         2      2  2      admin   just now
landscape*  maas/default  maas  available         0      -  -      admin   8 seconds ago
```

Enter to following to verify the default-series value for the model `landscape`:

```bash
juju model-config default-base

# output
ubuntu@22.04
```


## 4.2 Deploy applications

### Task 1: Deploy Landscape Scalable bundle

Check the existing juju model, there should be one called `landscape`:

```bash
juju models
```

In this model, deploy the `landscape-scalable` bundle:

```bash
juju deploy landscape-scalable
```

Watch for the completion of the bundle deployment:
```bash
watch -c juju status --color
```

![juju-controller](./images/os-cloud-provider5.png)

### Task 2: Verify the deployment

Run the following command that will also reaveal relations between applications:

```bash
juju status --relations

# output
Model      Controller       Cloud/Region  Version  SLA          Timestamp
landscape  maas-controller  maas/default  3.5.1    unsupported  12:38:52Z

App               Version  Status  Scale  Charm             Channel        Rev  Exposed  Message
haproxy                    active      1  haproxy           latest/stable   75  yes      Unit is ready
landscape-server           active      1  landscape-server  latest/stable  107  no       Unit is ready
postgresql        14.12    active      1  postgresql        latest/stable  345  no       Live master (14.12)
rabbitmq-server   3.9.13   active      1  rabbitmq-server   3.9/stable     188  no       Unit is ready

Unit                 Workload  Agent  Machine  Public address  Ports           Message
haproxy/0*           active    idle   0        192.168.100.12  80,443/tcp      Unit is ready
landscape-server/0*  active    idle   1        192.168.100.13                  Unit is ready
postgresql/0*        active    idle   2        192.168.100.15  5432/tcp        Live master (14.12)
rabbitmq-server/0*   active    idle   3        192.168.100.14  5672,15672/tcp  Unit is ready

Machine  State    Address         Inst id       Base          AZ       Message
0        started  192.168.100.12  os-compute01  ubuntu@22.04  default  Deployed
1        started  192.168.100.13  os-compute02  ubuntu@22.04  default  Deployed
2        started  192.168.100.15  os-compute03  ubuntu@22.04  default  Deployed
3        started  192.168.100.14  os-compute04  ubuntu@22.04  default  Deployed

Integration provider       Requirer                   Interface          Type     Message
haproxy:peer               haproxy:peer               haproxy-peer       peer
landscape-server:replicas  landscape-server:replicas  landscape-replica  peer
landscape-server:website   haproxy:reverseproxy       http               regular
postgresql:coordinator     postgresql:coordinator     coordinator        peer
postgresql:db-admin        landscape-server:db        pgsql              regular
postgresql:replication     postgresql:replication     pgpeer             peer
rabbitmq-server:amqp       landscape-server:amqp      rabbitmq           regular
rabbitmq-server:cluster    rabbitmq-server:cluster    rabbitmq-ha        peer
```

### Task 3: Log in to Landscape Web interface

Get the IP address of the HAProxy unit:

```bash
juju status haproxy

# output
Model      Controller       Cloud/Region  Version  SLA          Timestamp
landscape  maas-controller  maas/default  3.5.1    unsupported  12:39:53Z

App      Version  Status  Scale  Charm    Channel        Rev  Exposed  Message
haproxy           active      1  haproxy  latest/stable   75  yes      Unit is ready

Unit        Workload  Agent  Machine  Public address  Ports       Message
haproxy/0*  active    idle   0        **192.168.100.12**  80,443/tcp  Unit is ready

Machine  State    Address         Inst id       Base          AZ       Message
0        started  **192.168.100.12**  os-compute01  ubuntu@22.04  default  Deployed
```

My IP is `192.168.100.12`, so the URL will be `https://192.168.100.12`.

Use Firefox to access that IP. You can configure the initial user of Landscape and gain access to its management console.


### Task 3: Remove the landscape model

Remove the `landscape` juju model. This will remove any charms/applications that are contained in it.

```bash
juju destroy-model --no-prompt landscape
```

List and destroy the juju controller.

```bash
juju controllers
```

```bash
juju destroy-controller maas-controller --no-prompt
```

# 5 Deploy an OpenStack Cloud with Juju and MAAS !heading

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

![bundle](./images/bundle.png)


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

![juju-controller](./images/os-cloud-provider2-fundamentals.png)



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





# 6 Work with Software Defined Networks !heading

**Description:**

In this section, you manage the software defined networks in an OpenStack cloud
using Neutron.


## 6.1 Define the OpenStack External Network

**Description:**

In this exercise, you create the external network for the OpenStack cloud.


### Task 1: Define the OpenStack External Network

Source the `admin_openrc` file and create the Neutron external network.

```bash
source ~/admin_openrc
```

```bash
openstack network create Public_Network --external \
  --provider-physical-network physnet1 --provider-network-type flat --mtu 1300
```

You should see the details of the newly created external network listed.

Enter the following command to display the newly defined external network:


```bash
openstack network list
```

```bash
openstack network show Public_Network
```

You should see the ID and name of the external network listed.


Enter the following command to define the external subnet properties:

```bash
openstack subnet create --ip-version 4 \
  --allocation-pool start=192.168.100.150,end=192.168.100.199 \
  --gateway=192.168.100.1 --no-dhcp \
  --network Public_Network \
  --subnet-range 192.168.100.0/24 Public_Subnet
```

You should see the details of the newly created subnet listed.

Enter the following command to list the current subnets:

```bash
openstack subnet list
```

Enter the following command to show the current subnet details:

```bash
openstack subnet show Public_Subnet
```

------

## 6.2 WEB UI

## 6.2.1 Define the OpenStack External Network via WebUI

**To define the external network via the WebUI perform the following:**

1. Log into the dashboard as the `admin` user.
2. From the list of panels on the left select: `Admin > Network > Networks`.
3. Click `Create Network`.
4. On the `Create Network` screen, enter/select the following:
> `Network Name`: **Public_Network**<br/>
>`Enable Admin State`: **checked**<br/>
>`Shared`: **checked**<br/>
>`Create Subnet`: **unchecked**<br/>
1. Click `Create`.
2. In the `Network Name` column, click on `Public_Network`.
3. On the `Networks / Public_Network` screen, in the `Subnets` section, click `+Create Subnet`.
4. On the `Create Subnet` screen on the `Subnet` tab, enter/select the following:
> `Subnet Name`: **Public_Subnet**<br/>
> `Network Address`: 192.168.100.0/24<br/>
> `IP Version`: **IPv4**<br/>
> `Gateway IP` : **192.168.100.1**<br/>
> `Disable Gateway`: **unchecked**
9. Click `Next`.
10. On the `Subnet Details` tab, enter/select the following:
> `Enable DHCP`: **(unchecked)**<br/>
> `Allocation Pools`: **192.168.100.150,192.168.100.199**<br/>
> `Host Routes`: **(leave blank)**
11.  Click `Create`.

# 7 Work with Cloud Images !heading

**Description:**

In this section, you work with the OpenStack Glance service, using it to store and
manage cloud images.

## 7.1 Upload Images into Glance

**Description:**

In this exercise, you upload a cloud image to Glance. You then update the image by
adding custom properties to the image.

![glance](./images/glance1.png)



### Task 1: Download the Cloud Image

Use the following commands to create a directory for the cloud images:

```bash
mkdir ~/cloud_images
cd ~/cloud_images
```

Enter the following command to download Ubuntu Jammy minimal cloud image:

```bash
wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
```

When the file has finished downloading enter the following command to view its file type:

```bash
file ubuntu-22.04-minimal-cloudimg-amd64.img
```

You should see that it is of type QEMU QCOW Image (v2)

Enter the following command to display more information about the disk image:

```bash
qemu-img info ubuntu-22.04-minimal-cloudimg-amd64.img
```

Convert the image to `raw` format, this is due to the fact that is recommended to have raw images on Ceph backends:

```bash
qemu-img convert -f qcow2 -O raw ubuntu-22.04-minimal-cloudimg-amd64.img ubuntu-jammy.img
```

Inspect the format again:

```bash
qemu-img info ubuntu-jammy.img
```

**Note** the `virtual size`. You will not be able to launch workload instances from this image using a flavor with
a root disk smaller than this.


### Task 2: Upload the Cloud Image into Glance

Enter the following command to source in the openrc config file:

```bash
source ~/admin_openrc
```

To view the current list of images in the Glance server:

```bash
openstack image list
```

You should see no images listed yet, since the deployment doesn't come with any images.

To upload KVM the cloud image you just downloaded into the Glance server:

```bash
openstack image create --public --min-disk 3 --container-format bare \
  --disk-format raw --property architecture=x86_64 \
  --file ~/cloud_images/ubuntu-jammy.img --progress \
  "jammy"
```

You should see information about the image once the import has completed and the progress of uploading.

Enter the following command to view the current list of images again:

```bash
openstack image list
```

You should see the new images listed.

Enter the following command to display more information about the image:

```bash
openstack image show jammy
```


You should see the same information displayed after the image was uploaded
into Glance.

------

## 7.2 WEB UI

## 7.2.1 Upload the Cloud Image into Glance via WebUI

**To upload the cloud image via the WebUI perform the following:**

1. Log into the dashboard as the `admin` user.
2. From the list of tabs on the left select: `Admin > Compute > Images`.
3. Click `Create Image`.
4. On the `Create An Image` screen, enter/select the following (leaving all unspecified values with their default):
> `Image Name`: **jammy**<br/>
> `Description`: **ubuntu 22.04**<br/>
> `Source Type` -> `File` -> `Browse`<br/>
> `Format`: **RAW**<br/>
> `Architecture`: **x86_64**<br/>
> `Minimum Disk (GB)`: **3**<br/>
> `Minimum RAM (MB)`: **(leave blank)**<br/>
> `Visibility`: **Public**<br/>
> `Protected`: **no**
1. Click `Create Image`.
2. To update the metadata associated with the image select:  `Admin > Compute > Images`.
3. Click on the `Launch` drop down to the right of the image name and select `Update Metadata`.
4. On the `Update Image Metadata` page enter the following in the `Custom` input block under `Available Metadata: hw_disk_bus`.
5. Click the `+` next to the input block. The metadata key should populate the `Existing Metadata` section.
6. In the Existing Metadata section, locate the newly added metadata key and enter the following in the input block to the right of it: `virtio`.
7. Click `Save`.
8. In the Existing Metadata section, locate the newly added metadata key and enter the following in the input block to the right of it: `virtio`.

# 8 Configure an OpenStack Project !heading

**Description:**

In this section you create and configuration a project in OpenStack.

## 8.1 Create an OpenStack Project

**Description:**

In this exercise, you create a new OpenStack project and then create and assign
a new user to it.

### Task 1: Create a New Project

At the terminal of the MAAS server, enter the following commands to create
a new project:

```bash
cd ~ && source ~/admin_openrc
```

```bash
openstack project create --enable --description 'Student Project' StudentProject --domain admin_domain
```

### Task 2: Create and Assign a User to a Project

At the terminal of the MAAS server, enter the following command to create a 
new user and assign that user to a project:

```bash
openstack user create --project StudentProject --email \
  student@example.com --password openstack --enable student --domain admin_domain
```


To assign the user and project to the Member role:

```bash
openstack role add --project-domain admin_domain --user-domain admin_domain \
  --user student --project StudentProject Member
```


## 8.2 Configure Access to a Project in OpenStack

**Description:**

In this exercise, you use Juju to configure access to a project in OpenStack.

### Task 1: Use the student resource file

At the terminal of the MAAS server, copy the student openrc file to the home directory:

```bash
cp os_files/student_* ~/
```

```bash
source ~/student_openrc
```


## 8.3 Generate Key Pairs for Workload Instance Access

**Description:**

In this exercise, you generate a new key pair for workload instance access and
then import an existing public key


### Task 1: Generate a New Key Pair

At the terminal of the MAAS server, enter the following command to generate
the key pair:

```bash
source ~/student_openrc
```

```bash
openstack keypair create student-keypair > ~/.ssh/student-keypair.pem
```

A file named `~/.ssh/student-keypair.pem` should be created.

Verify the key file `~/.ssh/student-keypair.pem` is created:

```bash
ls -al ~/.ssh/student-keypair.pem
```

You should see something similar to:

```bash
-rw------- 1 ubuntu ubuntu 1684 Jun 16 01:20   /home/ubuntu/.ssh/student-keypair.pem
```

Permissions on the key file are set based on umask. They should be changed to `600`:

```bash
chmod 600 ~/.ssh/student-keypair.pem
```


### Task 2: Import a Public Key

At the terminal of the MAAS server, enter the following command to import an
existing key pair:

```bash
source ~/student_openrc
```

```bash
openstack keypair create --public-key ~/.ssh/id_rsa.pub existing-keypair
```

At the terminal of the MAAS server, enter the following command to view
existing key pairs:

```bash
openstack keypair list
```

You should see key pairs named existing-keypair and student-keypair and their
fingerprints listed.



## 8.4 Define a Security Group for ICMP Traffic

**Description:**

In this exercise, you define a security group that allows both incoming and outgoing
ICMP traffic.

**Note:**

By default, when you create a security group it will allow all outgoing IPv4 and IPv6
traffic. The examples in the following exercises are there to familiarize you with
the concept of `ingress` and `egress`.

If you ever do need to restrict egress traffic make sure to remove all default egress
rules from the security groups you apply to an instance or a port.


### Task 1: Define a Rule to Allow Incoming ICMP

At the terminal of the MAAS server, enter the following command to create a
security group for ICMP traffic:

```bash
source ~/student_openrc
```

```bash
openstack security group create --description 'Allow ICMP Traffic' \
  StudentProject_Allow_ICMP
```

You should see detailed information on the ICMP security group you just created.

To create the rules for the newly created ICMP security group:

```bash
openstack security group rule create --proto icmp \
  StudentProject_Allow_ICMP
```

You should see your ICMP ingress rule listed.

```bash
openstack security group rule create --proto icmp --egress \
  StudentProject_Allow_ICMP
```

You should see your ICMP egress rule listed.


To view the security group rules list inside StudentProject_Allow_ICMP security group, run the following command:

```bash
openstack security group rule list StudentProject_Allow_ICMP
```



## 8.5 Define a Security Group for SSH Traffic

**Description:**

In this exercise, you define a security group that allows both incoming and
outgoing SSH traffic.


##### Task 1: Define a Rule to Allow Incoming and Outgoing SSH


To define a rule allowing incoming SSH via the CLI perform the following:

At the terminal of the MAAS server, enter the following command to create
a security group for SSH traffic:

```bash
source ~/student_openrc
```

```bash
openstack security group create --description 'Allow SSH Traffic' \
  StudentProject_Allow_SSH
```

You should see detailed information on the SSH security group you just created.

To create rules for the newly created SSH security group:

```bash
openstack security group rule create --proto tcp \
  --dst-port 22 StudentProject_Allow_SSH
```

You should see your SSH ingress rule listed.

```bash
openstack security group rule create --proto tcp --egress \
  --dst-port 22 StudentProject_Allow_SSH
```

You should see your SSH egress rule listed.

To view the security group rules list in StudentProject_Allow_SSH security group, run the following command:

```bash
openstack security group rule list StudentProject_Allow_SSH
```



## 8.6 Define Quotas for a Project

**Description:**

In this exercise, you will modify the quotas for a project.

##### Task 1: Modify a Project's Quotas

At the terminal of the MAAS server, enter the following command to view the
quotas for the project StudentProject:

```bash
source ~/admin_openrc
```

```bash
openstack quota show StudentProject
```

You should see all quotas for project StudentProject.

At the terminal of the MAAS server, enter the following command to set new
quotas for the project StudentProject:

```bash
openstack quota set --cores 40 --ram 25600 --instances 20 --volumes 5 \
  --snapshots 5 --floating-ips 10 --secgroups 20 --secgroup-rules 200 StudentProject
```

At the terminal of the MAAS server, enter the following command to view the
newly set quotas for the project StudentProject:

```bash
openstack quota show StudentProject
```

You should see all quotas for project StudentProject.


## 8.7 Configure Virtual Networks for a Project

**Description:**

In this exercise, you create a private network, subnet and router for a project.


### Task 1: Create the Tenant Private Network

At the terminal of the `MAAS server`, enter the following command to read in
the environment for the StudentProject project.

```bash
source ~/student_openrc
```

Enter the following command to define the private network:

```bash
openstack network create StudentProject_Network --mtu 1300
```

You should see the details of the newly created tenant network.

Enter the following command to define the private subnet properties:

```bash
openstack subnet create --ip-version 4 \
  --allocation-pool start=10.20.30.10,end=10.20.30.199 \
  --gateway=10.20.30.1 --dhcp \
  --dns-nameserver 192.168.100.3 --dns-nameserver 8.8.8.8 \
  --subnet-range 10.20.30.0/24 \
  --network StudentProject_Network StudentProject_Subnet
```


You should see the details of the newly created private subnet.

Enter the following command to list the current networks:

```bash
openstack network list
```

You should see the StudentProject_Network network listed

Using the ID of the subnet associated with StudentProject_Network enter
the following command to view the details of the subnet:

```bash
openstack subnet list
```

```bash
openstack network show StudentProject_Network
openstack subnet show StudentProject_Subnet
```

You should see details of the private network and subnet listed.


### Task 2: Create a Router to Connect the Networks

At the terminal of the MAAS server, enter the following command to read in
the environment for the StudentProject project.

```bash
source ~/student_openrc
```

Enter the following command to create the router:

```bash
openstack router create StudentProject_Public_Router
```

You should see details on the newly created router.

Enter the following define the router's gateway:

```bash
openstack router set --external-gateway Public_Network StudentProject_Public_Router
```

If successful you should not see any output.

Enter the following command to add a router interface on the Private Network:

```bash
openstack router add subnet StudentProject_Public_Router StudentProject_Subnet
```

If successful you should not see any output.

![neutron-nets](./images/os-networks1-fundamentals.png)

Check details of the router:

```bash
openstack router show StudentProject_Public_Router
```

You should see details on the newly created router.

## 8.8 Assign Public IP Addresses to a Project

**Description:**

In this exercise, you allocate a floating IP to a project.


### Task 1: Allocate a Floating IP to a Project

At the terminal of the MAAS server, enter the following command to allocate a
floating IP:

```bash
source ~/student_openrc
```

```bash
openstack floating ip create Public_Network
```

You should see details on the allocated floating IP.


------

## 8.9 WEB UI

## 8.9.1 Create a project in OpenStack

### Task 1: Create a New Project

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


### Task 2: Create and Assign a User to a Project

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



## 8.9.2 Configure Access to a Project in OpenStack

**To create a project user resource file via the WebUI perform the following:**

1. In a web browser, point to the OpenStack Dashboard and log in as  `student`.
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

> When using the resource file downloaded the the WebUI you will be prompted for the project user's password.



## 8.9.3 Generate Key Pairs for Workload Instance Access

### Task 1: Generate a New Key Pair

**To generate a new keypair via the WebUI perform the following:**

1. In a web browser, point to the OpenStack Dashboard and log in as  `student`.
2. From the panels on the left select: `Project > Compute > Key pairs`.
3. You should see a list of existing key pairs. (There are probably none at this point).
4. Click `Create a Key Pair`.
5. In the `Create a Key Pair` screen, enter the following: `Key Pair Name`: `student-keypair`, `Key Type`: `SSH Key`.
7. Click `Create Key Pair`.
8. You should be prompted to download the private key of the newly generated key pair.
> **Important:**: It is imperative that you download the key pair when prompted because you will not be able to download it again later.
9. Once downloaded change permissions on the key pair and move it from your Downloads
directory to your `~/.ssh/` directory. At the terminal of the vhost enter the
following command:

```bash
chmod 600 ~/Downloads/student-keypair.pem
mv ~/Downloads/student-keypair.pem ~/.ssh
```

10. Copy this key to the `~/.ssh` directory of the `ubuntu` user on the `MAAS server`. At the terminal of the vhost enter the following command:

```bash
scp ~/.ssh/student-keypair.pem SHELL_USER@MAAS_IP:~/.ssh
```


## 8.9.4 Define a Security Group for ICMP Traffic

### Task 1: Define a Rule to Allow Incoming ICMP

**To define a rule allowing incoming ICMP via the WebUI perform the following:**

1. In a web browser point, to the OpenStack Dashboard and log in as  `student`.
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
13.  Click `Add`. You should see your new Egress rule listed.


## 8.9.5 Define a Security Group for SSH Traffic

##### Task 1: Define a Rule to Allow Incoming and Outgoing SSH

**To define a rule allowing incoming SSH via the WebUI perform the following:**

1. In a web browser point, to the OpenStack Dashboard and log in as  `student`.
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
>`CIDR`: **0.0.0.0/0**<br/>
13. Click `Add`. You should see your new `Egress` rule listed.


## 8.9.6 Define Quotas for a Project

##### Task 1: Modify a Project's Quotas

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


## 8.9.7 Configure Virtual Networks for a Project

### Task 1: Create the Tenant Private Network

**To create a tenant private network via the WebUI perform the following:**

1. Log into the dashboard as the `student` user.
2. From the list of panels on the left select: `Project > Network > Networks`.
3. Click `Create Network`.
4. On the `Create Network` screen `Network` tab, enter/select the following:
> `Name`: **StudentProject_Network**<br/>
> `Enable admin state`: **checked**<br/>
> `Create Subnet`:**(checked)**
5. Click`Next`.
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
9. Click ``Create``


### Task 2: Create a Router to Connect the Networks

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
> `Subnet`: ``StudentProject_Network 10.20.30.0/24 (StudentProject_Subnet)`<br/>
> `IP Address (optional)`: **(leave blank)**<br/>
10. Click `Submit`.


## 8.9.8 Assign Public IP Addresses to a Project

##### Task 1: Allocate a Floating IP to a Project

**To allocate a floating IP to a project via the WebUI perform the following:**

1. In a web browser, log into the Dashboard as `student`.
2. From the panels on the left select: `Project > Network > Floating IPs`.
3. Click `Allocate IP To Project`.
4. On the `Allocate Floating IP` screen, from the Pool drop-down list, select: `Public_Network`.
5. Click `Allocate IP`. You should see that an IP address has been allocated to the project.

# 9 Work with Cloud Workload Instances !heading

**Description:**

In this section, you use the OpenStack Nova service to launch and work with cloud instances.

## 9.1 Define Custom Instance Sizing Flavors

**Description:**

In this exercise, you create a new instance-sizing flavor.

### Task 1: Define a New Instance Sizing Flavor

At the terminal of the MAAS server, enter the following commands to create
a new instance flavor:

```bash
source ~/admin_openrc
```

```bash
openstack flavor create --vcpus 2 --ram 1024 --disk 5 --ephemeral 0 \
  --swap 0 --public m1.smaller
```

You should see the details on the newly created flavor listed.



## 9.2 Define Host Aggregates

**Description:**

In this exercise, you create two host aggregates for the compute nodes.

![aggregates](./images/host_aggregates.png)



### Task 1: Define a Host Aggregate

At the terminal of the MAAS server, enter the following commands to define
a host aggregate called `kvm`:

```bash
source ~/admin_openrc
```

```bash
openstack aggregate create --zone nova kvm
```

You should see details on the newly created host aggregate with no hosts listed.

Run the following command to list the available hosts:

```bash
openstack host list --zone nova
# output
+-------------------+---------+------+
| Host Name         | Service | Zone |
+-------------------+---------+------+
| os-compute03.maas | compute | nova |
| os-compute04.maas | compute | nova |
| os-compute01.maas | compute | nova |
| os-compute02.maas | compute | nova |
+-------------------+---------+------+
```

You should see a listing of available hosts.

Add all of the `os-compute` compute hosts to the `kvm`  host aggregate:

```bash
openstack aggregate add host kvm $(openstack host list --zone nova | grep 'maas' | awk 'NR==1 {print $2}')
openstack aggregate add host kvm $(openstack host list --zone nova | grep 'maas' | awk 'NR==2 {print $2}')
openstack aggregate add host kvm $(openstack host list --zone nova | grep 'maas' | awk 'NR==3 {print $2}')
openstack aggregate add host kvm $(openstack host list --zone nova | grep 'maas' | awk 'NR==4 {print $2}')
```

For each execution of the command you should see details of the host aggregate
with the host you added being listed as a value of the hosts field.

Verify your host have been added with:

```bash
openstack aggregate show kvm
# output
+-------------------+----------------------------------------------------------------------------+
| Field             | Value                                                                      |
+-------------------+----------------------------------------------------------------------------+
| availability_zone | nova                                                                       |
| created_at        | 2024-07-11T13:29:57.000000                                                 |
| deleted_at        | None                                                                       |
| hosts             | os-compute01.maas, os-compute02.maas, os-compute03.maas, os-compute04.maas |
| id                | 1                                                                          |
| is_deleted        | False                                                                      |
| name              | kvm                                                                        |
| properties        |                                                                            |
| updated_at        | None                                                                       |
| uuid              | 80a7e52a-0a4e-4c5a-b66a-89156fef72ea                                       |
+-------------------+----------------------------------------------------------------------------+
```

You should see the host listed as the value for the hosts field.


### Task 2: Define a Key-Value property for a Host Aggregate

At the terminal of the MAAS server, enter the following to add a key-value property
to the `KVM` host aggregate:

```bash
source ~/admin_openrc
```

```bash
openstack aggregate set --property kvm=true kvm
```

```bash
openstack aggregate show kvm
```

You should see the new key-value pair listed as the value for the properties field.




## 9.3 Define a Custom Instance Sizing Flavor for a Host Aggregate

**Description:**

In this exercise, you create a new instance-sizing flavor that corresponds to
a host aggregate.


### Task 1: Define a New Instance Sizing Flavor


At the terminal of the MAAS server, enter the following command to create
a two new flavors, one for each hypervisor:

```bash
source ~/admin_openrc
```

```bash
openstack flavor create --vcpus 1 --ram 512 --disk 5 --public kvm.smaller
```

You should see details on the newly created flavor listed.

Enter the following command to define a key-value pair for the `KVM` flavor
that matches the key-value pair in the host aggregate:

```bash
openstack flavor set --property \
  aggregate_instance_extra_specs:kvm=true kvm.smaller
```

Enter the following command to display the flavor:

```bash
openstack flavor show kvm.smaller
```

You should see the property listed as the value for the  `properties` field.


### Task 2: Enable the Scheduler Filter

By default, the Controller node does not have the scheduling filter required to do
filtering based on the extra_specs you added to the flavor.

We need to add a special filter called `AggregateInstanceExtraSpecsFilter` to the default list already present
on the `nova-cloud-controller` unit.

To update the value for `scheduler-default-filters`, enter the following command:

```bash
DEFAULT_FILTERS=`juju exec -u nova-cloud-controller/0 "grep enabled_filters /etc/nova/nova.conf" \
| cut -d " "  -f 3-`
```

Verify the value of DEFAULT_FILTERS:

```bash
echo $DEFAULT_FILTERS
```

If the value of DEFAULT_FILTERS is empty, then command did not work as expected and needs to be fixed.

```bash
juju config nova-cloud-controller \
  scheduler-default-filters=$DEFAULT_FILTERS,AggregateInstanceExtraSpecsFilter
```

Enter the following command to display the updated `scheduler-default-filters`.

```bash
juju config nova-cloud-controller scheduler-default-filters
```


Make sure that the nova charm finishes executing the "config-changed" hook.

```bash
juju status nova-cloud-controller
```



## 9.4 Create a cloud Instance

**Description:**

In this exercise, you will launch a cloud instance.

### Task 1: Create an Instance

At the terminal of the MAAS server, perform the following steps to
create a new cloud instance:

```bash
source ~/student_openrc
```

Create the cloud instance with the following command:

```bash
openstack server create --availability-zone nova \
  --image 'jammy' --flavor m1.smaller \
  --key-name student-keypair --security-group StudentProject_Allow_SSH \
  --nic net-id=$(openstack network list | grep StudentProject_Network | awk '{ print $2 }') jammy1
```

You should see the the details of the newly created cloud instance.

Run the following command to view all defined instances:

```bash
openstack server list
```

You should see the IDs, names, status and networks of defined cloud instances.

Rerun the command periodically until the Status shows ACTIVE or use the following command:

```bash
watch openstack server list
```



## 9.5 Expose a Cloud Workload to the External Network

**Description:**

In this exercise, you assign a floating IP address to an instance and edit its
security groups to expose it to the external network.


### Task 1: Assign a Floating IP to an Instance

At the terminal of the MAAS server, perform the following steps to assign a
floating IP address to a cloud instance:

```bash
source ~/student_openrc
```

Retrieve a list of currently defined floating IP addresses:

```bash
export INSTANCE_FLOATING_IP=$(openstack floating ip list | grep 192 | awk '{ print $4 }')
```

Associate the floating IP address with your cloud instance:

```bash
openstack server add floating ip jammy1 $INSTANCE_FLOATING_IP
```

Retrieve a list of currently defined floating IP addresses again:

```bash
openstack floating ip list
```

You should now see the floating IP address you used associated with a fixed IP address.


### Task 2: Ping the floating IP

In a terminal on the MAAS server, enter the following command to ping the workload
instance:

```bash
ping -c 4 $INSTANCE_FLOATING_IP
```

You should see that the destination host is unreachable. Although the IP is assigned
to the instance, you will not see a response because it is not a member of a security
group that allows ICMP. In the next task you will add the instance to the correct
security group to allow ICMP.


### Task 3: Edit Instance Security Groups

At the terminal of the MAAS server, perform the following steps to add the cloud
instance to the security group allowing ICMP traffic:

```bash
source ~/student_openrc
```

```bash
# check the current security groups
openstack server show jammy1
```

```bash
openstack server add security group jammy1 StudentProject_Allow_ICMP
```

Verify the `StudentProject_Allow_ICMP` security group was added with the following:

```bash
openstack server show jammy1
```

You should see both **StudentProject_Allow_ICMP** and **StudentProject_Allow_SSH** listed.


### Task 4: Ping the floating IP again

In a terminal on the MAAS server, enter the following command to ping the
workload instance:

```bash
ping -c 4 $INSTANCE_FLOATING_IP
```

You should see a response form the instance.



------

## 9.6 WEB UI

## 9.6.1 Define Custom Instance Sizing Flavors

**To define a new instance sizing flavor via the WebUI perform the following:**

1. In a web browser, point to the OpenStack Dashboard and log in as the  `admin` user.
2. From the panels on the left select `Admin > Compute > Flavors`.
> You should see the currently defined sizing flavors.
3. Click `Create Flavor`.
4. In the `Create Flavor` window, under the `Flavor Information` tab, enter/selec the following:
> `Name`: **m1.smaller**<br/>
> `ID`: **auto**<br/>
> `VCPUs`: **1**<br/>
> `RAM MB`: **512**<br/>
> `Root Disk GB`: **5**<br/>
> `Ephemeral Disk GB`: **0**<br/>
> `Swap Disk MB`: **0**<br/>
> `RX/TX Factor`: **1**
5. Click `Create Flavor`. You should see your new flavor in the list.


## 9.6.2 Define Host Aggregates

##### Task 1: Define a Host Aggregate

**To define a host aggregate via the WebUI perform the following:**

1. In a web browser, point to the OpenStack Dashboard and log in as the  `admin` user.
2. From the panels on the left select `Admin > Compute > Host Aggregates`. You should see the currently defined host aggregates and availability zones.
3. Click `Create Host Aggregate`.
4. In the `Create Host Aggregate` window, on the `Host Aggregate Information` tab, enter/select the following:
> `Name`: **KVM**<br/>
> `Availability Zone`: **nova**
5. On the `Manage Hosts Within Aggregate` tab, in the `All available hosts` column,
click on the `Plus sign` next to `os-compute02` and `os-compute03` to move
them under the `Selected hosts` column.
6. Click `Create Host Aggregate`.


### Task 2: Define a Key-Value property for a Host Aggregate

1. In a web browser, point to the OpenStack Dashboard and log in as the `admin` user.
2. From the panels on the left select `Admin > Compute > Host Aggregates`. You should see the currently defined host aggregates and availability zones.
3. In the `Host Aggregates` window, in the `Host Aggregates` section select the dropdown menu under `Edit Host Aggregate` for the `KVM` host aggregate.
4. Select `Update Metadata`.
5. In the `Available Metadata` column, type `kvm` in the `Custom` input box and click on the `plus sign`.
6. In the `Existing Metadata` column, type `true` in the input box next to `kvm`.
7. Click `Save`. You should see `kvm = true` in the `Metadata` column for the `kvm` host aggregate.


## 9.6.3 Define a Custom Instance Sizing Flavor for a Host Aggregate

### Task 1: Define a New Instance Sizing Flavor

1. In a web browser, point to the OpenStack Dashboard and log in as the  `admin` user.
2. From the panels on the left select `Admin > Compute > Flavors`. You should see the currently defined sizing flavors.
3. Click `Create Flavor`.
4. In the `Create Flavor` window, enter/select the following:
> `Name`: **kvm.smaller**<br/>
> `ID`: **auto**<br/>
> `VCPUs`: **1**<br/>
> `RAM MB`: **512**<br/>
> `Root Disk GB`: **5**<br/>
> `Ephemeral Disk GB`: **0**<br/>
> `Swap Disk MB`: **0**<br/>
> `RX/TX Factor`: **1**
5. Click `Create Flavor`. You should see your new flavor in the list.
7. From `Actions` for the `kvm.smaller` flavor.
8. Select `Update Metadata`.
9. In the `Available Metadata` column, type `aggregate_instance_extra_specs:kvm` in the `Custom` input box and click on the `plus sign`.
10. In the `Existing Metadata` column, type true in the input box next to `aggregate_instance_extra_specs:kvm`.
11. Click `Save`. You should see `Yes` in the `Metadata` column for the `kvm.smaller` flavor.


## 9.6.4 Create a cloud Instance

### Task 1: Create an Instance

1. Log into the OpenStack Dashboard as `student`.
2. From the panels on the left, select: `Project > Compute > Instances`.
3. Click `Launch Instance`.
4. In the `Launch Instance` window in the `Details` pane enter/select the following:
> `Instance Name`:**jammy1**<br/>
> `Availability Zone`: **nova**<br/>
> `Count`: **1**
5. Click `Next`.
6. In the `Launch Instance` window in the `Source` pane enter/select the following:
> `Select Boot Source`: **Image**<br/>
> `Create New Volume`: **No**
7. Scroll down to the `Available` images and click on the up arrow to the right of the `jammy` image.
8. The `jammy` image will move up to the `Allocated` section.
9. Click `Next`.
10. In the `Launch Instance` window in the Flavor pane scroll down to the Available flavors and click on the up arrow to the right of the `m1.smaller` flavor.
11. The `m1.smaller` flavor will move up to the Allocated section.
12. Click `Next`.
13. In the `Launch Instance` window in the `Networks` pane scroll down to the
`Available` networks and click on the + to the right of the `StudentProject_Network` network.
14. The `StudentProject_Network` network will move up to the `Allocated` section.
15. Click `Next` twice.
16. In the `Launch Instance` window in the `Security Groups` pane scroll down to
the `Available` security groups and click on the up arrow to the right of the `StudentProject_Allow_SSH` security group.
17. The `StudentProject_Allow_SSH` security group will move up to the `Allocated` section.
18. Click `Next`.
19. In the `Launch Instance` window in the `Key Pair` pane scroll down to the
    `Available` key pairs and click on the up arrow to the right of the `student-keypair` key pair.
20. The `student-keypair` key pair will move up to the Allocated section.
21. Click `Launch Instance`.

> You should see your new instance in the list. Initially its status should be `Build`
> and its task should be `Block Device Build` and then `Spawning`. This should
> transition to `Active` status with a power state of `Running` when it finishes
> deploying.


## 9.6.5 Expose a Cloud Workload to the External Network

### Task 1: Assign a Floating IP to an Instance

**To assign a floating IP via the WebUI perform the following:**

1. Log into the OpenStack Dashboard as `student`.
2. From the panels on the left, select: `Project > Compute > Instances`.
3. Next to the running instance in the Actions column select `Associate Floating IP`. from the `Create Snapshot` drop-down list.
4. On the manage `Floating IP Associations` screen, select the following:
> `IP Address`: **(select the first address in the list)**<br/>
> `Port to be associated`:**(accept the default)**
5. Click `Associate`.
6. In the IP Address column next to the running instance, you should see the floating IP address listed.


### Task 3: Edit Instance Security Groups

**To edit an instance security group via the WebUI perform the following:**

1. Log into the OpenStack Dashboard as `student`.
2. Next to the running instance, in the `Actions` column, select `Edit Security Groups` from the `Create Snapshot` drop-down list.
3. In the `Edit Instance` window, in the `Security Groups` pane, click the `+` next to the `StudentProject_Allow_ICMP` security group. The security
group should move to the `Instance Security Groups` pane.
4. Click `Save`.

# 10 Work with OpenStack Storage !heading

**Description:**

In this section, you work with Block storage and Object storage.

## 10.1 Attach Volume Storage to a Cloud Workload Instance

**Description:**

In this exercise, you create a volume and attach it to an instance.

![cinder1](./images/cinder1.png)


### Task 1: Create a Storage Volume

At the terminal of the MAAS server, perform the following steps to create a
storage volume:

```bash
source ~/student_openrc
```

```bash
openstack volume create --availability-zone nova --size 5 \
  --description 'StudentProject Volume 01' volume1
```

You should see the details listed for the newly created volume.

```bash
openstack volume list
```

```bash
openstack volume show volume1
```

### Task 2: Attach a Volume to an Instance

![cinder2](./images/cinder2.png)

At the terminal of the MAAS server, perform the following steps to retrieve
the volume ID of the storage volume:

```bash
source ~/student_openrc
```

```bash
VOLUME_ID=$(openstack volume list | grep volume1 | awk '{print $2}')
```

Attach the volume to an instance be performing the following:

```bash
openstack server add volume --device /dev/vdb jammy1 $VOLUME_ID
```

List the instance details to see the attached volume ID:

```bash
openstack server show jammy1 | grep volumes
```

You should see a line beginning with **volumes_attached**
listing the volume ID(s) attached to the instance.

Retrieve the key-pair name used with the instance with the following:

```bash
openstack server show jammy1 | grep key_name
```

You should see a line beginning with key_name listing the name of the key
pair used by the instance.

Retrieve the floating IP of the instance with the following:

```bash
openstack server show jammy1 | grep addresses
```

You should see a line beginning with addresses listing the IP addresses
associated with the instance. The `192.168.100.x` address will be the
floating IP.



### Task 3: Check the Volume

At the terminal of the MAAS server, enter the following command to ssh
to the instance:

```bash
ssh -i ~/.ssh/student-keypair.pem ubuntu@$INSTANCE_FLOATING_IP
```

Enter the following command to view the disks attached to the instance:

```bash
sudo fdisk -l
```

You should see the volume listed as one of the disks. Optionally, you can create partitions on the volume, format with a filesystem and mount it with either `parted` or `fdisk`.

Finally, exit the VM and delete all the existing VMs and volumes:

```bash
exit
```

```bash
openstack server list
```

```bash
openstack server delete jammy1
sleep 5
openstack volume delete volume1
```

There is a `sleep` between commands to allow the volume to become `available` again. After the instance is deleted, volume attachment also gets deleted and volume transitions from `in-use` to `available`. A volume can't be deleted if the status is `in-use`.


## 10.2 Upload Objects into Swift

**Description:**

In this exercise, you upload files as objects into Swift.

### Task 1: Upload a File to Swift

At the terminal of the MAAS server, enter the following command to source
in the `admin_openrc` file:

```bash
source ~/admin_openrc
```

**Note:** We need to source in the admin_openrc file rather the then project specific `.rc`
file because we will be uploading the files to the Admin project and then make
it publicly accessible. This way it is available to all tenants in the private
cloud.

Enter the following command to create a new container for the files:

```bash
openstack container create mydata
```

You should see the details of your newly created container.

Enter the following command to display the newly created container:

```bash
openstack container list
```

You should see the new container listed.

Enter the following command to view the status of the container:

```bash
openstack container show mydata
```

Notice the object_count: line. You should see that the container contains
zero objects.

Enter the following commands to create a directory and some files:

```bash
mkdir ~/mydata
```

```bash
echo "my file 1" > ~/mydata/myfile01.txt
echo "my file 2" > ~/mydata/myfile02.txt
```

Enter the following commands to upload the files to the container:

```bash
cd ~/mydata
```

```bash
openstack object create mydata *
```

You should see details on the two files uploaded.

Enter the following command to view the status of the container:

```bash
openstack container show mydata
```

Notice the `object_count:` line; you should see that the container now
contains two objects.

Enter the following command to list the objects in the container:

```bash
openstack object list mydata
```

You should see the files listed.



### Task 2: Set ACLs on a Container

Since all swift client command features have not yet been implemented in the
common client openstack we're going to use `python3-swiftclient` instead which 
is already installed on the MAAS server.

Enter the following command to display information about the mydata container:

```bash
swift stat mydata
```

Notice that there are no Read or Write ACLs. This is essentially a private
container.

Enter the following command to add a Read ACL that will make the container
publicly accessible:

```bash
swift post mydata --read-acl .r:*
```

Enter the following command to display information about the container again:

```bash
swift stat mydata
```

You should see the Read ACL listed now.




## 10.3 Download an Object from the Object Store

**Description:**

In this exercise, you download an object that was previously uploaded into Swift.

**Note:** You should have uploaded the contents of the `~/mydata` directory to the
Object Store container `mydata` before performing this exercise.


### Task 1: Download an Object from the Object Store with the openstack client

At the terminal of the `MAAS server`, enter the following command to source in the
`admin_openrc` file:

```bash
cd ~; source ~/admin_openrc
```

Enter the following command to display the objects (files) from the container
mydata within the object store:

```bash
openstack object list mydata
```

Enter the following commands to save the file `myfile01.txt` from the object store:

```bash
cd ~
openstack object save mydata myfile01.txt
```

Verify the file has been saved from the object store with the following command:

```bash
ls -l ~/myfile01.txt
```


### Task 2: Download an Object from the Object Store with wget

At the terminal of the `MAAS server`, enter the following command source in the
`admin_openrc` file:

```bash
source ~/admin_openrc
```

Enter the following command to display the public URL to access the Object Store:

```bash
export OBJECT_STORE_URL=$(openstack endpoint list -f value \
  -c "Service Type" -c "URL" -c "Interface" | grep object-store | grep public | awk '{print $3}')
```

Enter the following command to view the files that are in the `mydata` container:

```bash
openstack object list mydata
```

You should see the files listed.

Enter the following commands to download the `myfile01.txt`file:

```bash
wget $OBJECT_STORE_URL/mydata/myfile02.txt --ca-certificate=/home/ubuntu/snap/openstackclients/common/root-ca.crt
```

You should see that the myfile02.txt file was downloaded into your current directory.

Enter the following command to view the contents of the myfile02.txt file you downloaded:

```bash
cat myfile02.txt
```

You should see the contents that you wrote to the file.


------


## 10.4 WEB UI

## 10.4.1 Attach Volume Storage to a Cloud Workload Instance

### Task 1: Create a Storage Volume

**To create a storage volume via the WebUI perform the following:**

1. Log into the OpenStack Dashboard as `student`.
2. From the panels on the left, select: `Project > Volumes > Volumes`.
3. click `Create Volume`.
4. On the `Create Volume` screen, enter/select the following:
> `Volume Name`: **volume1**<br/>
> `Description`: **StudentProject Volume 01**<br/>
> `Volume Source`: **No source, empty volume**<br/>
> `Type`: **No volume type**<br/>
> `Size (GB)`: **1**<br/>
> `Availability Zone`: **nova**
1. Click `Create Volume`. You should see the new volume listed.


### Task 2: Attach a Volume to an Instance

**To attach a volume to an instance via the WebUI perform the following:**

1. Log into the OpenStack Dashboard as `student` and go to `Project > Volumes > Volumes`
2. Next to the `volume1` volume, in the Actions column, from the `Edit Volume` drop-down list, select `Manage Attachments`.
3. On the `Manage Volume Attachments` screen from the `Attach to Instance` drop-down list, select one of the running instances.
4. Click `Attach Volume`.
5. You should see the instance name listed under the `Attached` to column.
6. From the panels on the left, select: `Project > Compute > Instances`.
7. Click on the instance name of the instance you attached the volume to.
8. On the `Instances / VM_NAME` screen under `Volumes Attached`, you should see the volume listed
9. Note the key pair used by the instance. This will be located under the `Metadata` section and listed as `Key Name`.
10. Also note the instances floating IP. This should be the second IP address listed in the `IP Addresses` section adjacent to the `Network` name.
11. We will refer to these as `INSTANCE_KEYPAIR` and `INSTANCE_FLOATING_IP`.




## 10.4.2 Upload Objects into Swift

**Description:**

### Task 1: Upload a File to Swift

**To upload files to swift via the WebUI perform the following:**

1. Log into the OpenStack Dashboard as `admin`.
2. From the panels on the left, select: `Project > Object Store > Containers`.
3. In the `Containers` pane, click `+ Container`.
4. On the `Create Container` screen, enter/select the following:
> `Container Name`: **mydata**<br/>
> `NotPublic`: **selected**
5. Click `Submit`.
6. In the `Containers` pane, click on the container `mydata`.
7. In the `Containers` pane, click on the `Upload File` icon (located next to the trashcan on the right side of the pane).
8. On the `Upload File To: mydata` screen, enter/select the following:
> `File`:Click `Browse`.
9. Select a small file from your local (student machine) file system and click `Open`.
10.  Click `Upload File`. You should see the file listed.


### Task 2: Set ACLs on a Container

**To set ACLs on a container via the WebUI perform the following:**

1. To perform this task via the OpenStack Dashboard, do the following:
2. Log into the OpenStack Dashboard as `admin`.
3. From the panels on the left, select: `Project > Object Store > Containers`.
4. In the `Containers` pane, click on the container `mydata`.
5. In the `mydata` info box, enter/select the following:
> `Public Access`: **(checked)**
6. You should see a link named `link` next to the checked `Public Access` box.

### Task 3: Download an Object from the Object Store via the WebUI

1. Log into the OpenStack Dashboard as `admin`.
2. From the panels on the left, select: `Project > Object Store > Containers`.
3. In the `Containers` pane, click on the container `mydata`.
4. In the `mydata` files box, click `Download` to the right of the file you wish to save locally.

> This method will save the file to the local (student) machine and not to the MAAS server.

# 11 Configure Juju to Use OpenStack as a Provider !heading

**Description:**

In this section, you configure Juju to use OpenStack as a provider. You then use
Juju to deploy services onto the OpenStack cloud.


## 11.1 Generate Simplestreams Metadata for a Private Cloud

**Description:**

In this exercise, you use Juju to deploy `glance-simplestreams-sync` charm to provide
the cloud images to be used in a private OpenStack cloud.


### Task 1: Inspect the YAML file for Glance Simplestreams Sync

In a terminal on the MAAS server the `~/os_files/glance-simplestreams-sync.yaml` file
already exists, just inspect the file:

```bash
cat ~/os_files/glance-simplestreams-sync.yaml
# output
glance-simplestreams-sync:
  use_swift: True
  run: True
  frequency: hourly
  region: RegionOne
  image_import_conversion: True
  snap-channel: 'latest/edge'
  mirror_list: '[{url: "https://cloud-images.ubuntu.com/releases/", name_prefix: "ubuntu:released"...
```


### Task 2: Deploy Glance Simplestreams Sync

Enter the following command to deploy `Glance Simplestreams Sync`:

```bash
juju deploy --to=lxd:3 --base ubuntu@22.04 \
  --config ~/os_files/glance-simplestreams-sync.yaml \
  --channel 2024.1/stable \
  glance-simplestreams-sync
```

**Note:** You need to deploy with the `jammy` series as it's the one compatible with `Openstack Caracal` release.

Add the relation from Glance Simplestreams Sync to Keystone (authentication and authorization) and Vault (certificates) with:

```bash
juju integrate glance-simplestreams-sync keystone
juju integrate glance-simplestreams-sync vault
```

You can use the following command to view the status of the charm deployment:

```bash
watch -c juju status glance-simplestreams-sync --color
```


## 11.2 Configure Juju to Use OpenStack as a Provider

**Description:**

In this exercise, you configure Juju to manage a project in a private OpenStack
cloud.

### Task 1: Create the cloud my-openstack

On the MAAS server run the following to have environment variables set:

```bash
source ~/student_openrc
```

Then, add the cloud definition for your Openstack cloud by running the following:

```bash
juju add-cloud --client
```

When prompted enter the following values:
> `Select cloud type:`: **openstack**<br/>
> `Enter a name for your openstack cloud:`: **my-openstack**<br/>
> `Enter the API endpoint url for the cloud`: **https://192.168.100.xxx:5000/v3**<br/>
> `Enter a path to the CA certificate for your cloud if one is required to access it [/tmp/root-ca.crt]`: **Leave as it is**<br/>
> `Select one or more auth types separated by commas`: **userpass**<br/>
> `Enter region [RegionOne]`: **Leave blank**<br/>
> `Enter the API endpoint url for the region [use cloud api url]`: **Leave blank**<br/>
> `Enter another region? (y/N)`: **N**<br/>

On the MAAS server, add the credentials for the newly added cloud my-openstack
by running the following:

```bash
juju add-credential my-openstack --client
```

When prompted enter the following values:
> `Enter credential name`: **student**<br/>
> `Select region`: **Leave blank**<br/>
> `Enter username`: **student**<br/>
> `Enter password`: **openstack**<br/>
> `Enter tenant-name`: **StudentProject**<br/>
> `Enter tenant-id (optional)`: **Leave blank**<br/>
> `Enter version (optional)`: **3**<br/>
> `Enter domain-name (optional):`: **Leave blank**<br/>
> `Enter project-domain-name (optional):`: **admin_domain**<br/>
> `Enter user-domain-name (optional):`: **admin_domain**<br/>
>
> Leave the rest of the fields blank.
> 
> You should see output similar to the following:
> ```console
> Credential "student" added locally for cloud "my-openstack".
> ```


### Task 2: Create the configuration file used for bootstrapping

Retrieve the product-streams public URL with the following:

```bash
source ~/admin_openrc

openstack endpoint list --service product-streams -f json | \
  jq -r '.[] | select(.Interface=="public").URL'
```

We will refer to this value as the SWIFT_URL

On the MAAS server, the fine named `~/os_files/my-config.yaml` already exists.
Edit it in a text editor and replace the `XXX` with the IP from the previous command:   

Enter the following values in the file:

```bash
cat ~/os_files/my-config.yaml
# output
network: StudentProject_Network
external-network: Public_Network
image-metadata-url: https://192.168.100.XXX:443/swift/v1/simplestreams/data/
default-base: ubuntu@22.04
ssl-hostname-verification: false
```

Edit the file with the Swift URL:

```bash
vim ~/os_files/my-config.yaml
```



### Task 3: Bootstrap Juju on OpenStack

Enter the following commands to allocate four floating IPs to the project:

```bash
source ~/student_openrc
```

```bash
openstack floating ip create Public_Network
openstack floating ip create Public_Network
openstack floating ip create Public_Network
openstack floating ip create Public_Network
```

Create a new flavor for the instances created with Juju:

```bash
source ~/admin_openrc
```

```bash
openstack flavor create --vcpus 2 --ram 2048 --disk 10 --ephemeral 0 \
  --swap 0 --public kvm.node
```

```bash
openstack flavor set --property \
  aggregate_instance_extra_specs:kvm=true kvm.node
```

Enter the following command to bootstrap Juju on the OpenStack cloud:

```bash
juju bootstrap --config ~/os_files/my-config.yaml \
  --bootstrap-constraints="mem=2G cores=2 allocate-public-ip=true" \
  --constraints="mem=2G" my-openstack my-controller
```

Bootstrapping Juju controller inside Openstack is going to take around 15 minutes.

When the juju bootstrap command has finished, enter the following command to
view the status of the Juju environment:

```bash
juju status -m controller
```

You should see that the environment is bootstrapped.




## 11.3 Deploy a Landscape Bundle on OpenStack with Juju

**Description:**

In this exercise, you deploy an application bundle using Juju.


### Task 1: Setup the cloud environment

At the terminal of the MAAS server, enter the following command to list the
available controllers:

```bash
juju controllers
```

The controller `my-controller` should be listed as the active controller (has
an asterisk next to the controller name)

If the controller `my-controller` is not listed as the active controller use
the following command to switch the controller:

```bash
juju switch my-controller
```

Enter the following command to view the status of the OpenStack Juju environment:

```bash
juju status -m controller
```


### Task 2: Deploy the Landscape Application Bundle

On the MAAS server you should have the file
`~/os_files/landscape_bundle.yaml` file:

```bash
cat ~/os_files/landscape_bundle.yaml
# output
default-base: ubuntu@22.04/stable
applications:
  haproxy:
    charm: haproxy
    channel: latest/stable
    num_units: 1
    to:
    - "0"
    expose: true
    options:
      default_timeouts: queue 60000, connect 5000, client 120000, server 120000
      global_default_bind_options: no-tlsv10
      services: ""
      ssl_cert: SELFSIGNED
    constraints: arch=amd64
  landscape-server:
    charm: landscape-server
    channel: latest/stable
    num_units: 1
    to:
    - "1"
  postgresql:
    charm: postgresql
    channel: latest/stable
    num_units: 1
    to:
    - "2"
    options:
      extra_packages: python*-apt postgresql-contrib postgresql-.*-debversion postgresql-plpython.*
      max_connections: 500
      max_prepared_transactions: 500
    storage:
      pgdata: rootfs,5M
  rabbitmq-server:
    charm: rabbitmq-server
    channel: 3.9/stable
    num_units: 1
    to:
    - "3"
    options:
      consumer-timeout: 259200000
machines:
  "0":
    constraints: arch=amd64 instance-type=kvm.node
  "1":
    constraints: arch=amd64 instance-type=kvm.node
  "2":
    constraints: arch=amd64 instance-type=kvm.node
  "3":
    constraints: arch=amd64 instance-type=kvm.node
relations:
- - landscape-server:amqp
  - rabbitmq-server:amqp
- - landscape-server:website
  - haproxy:reverseproxy
- - landscape-server:db
  - postgresql:db-admin
```

Enter the following command to deploy the Wordpress application bundle:

```bash
juju add-model landscape

juju set-model-constraints allocate-public-ip=true

juju deploy ./os_files/landscape_bundle.yaml
```

Deploying the bundle inside Openstack will take around 30 minutes. Access the Landscape Web UI after the deployment finishes.

Enter the following command to monitor the deployment of the bundle:

```bash
watch -c juju status --color
```

You should see the applications defined in the bundle start to deploy.


![juju-controller](./images/openstack_cloud_provider.png)

After it's finished deploying, you can access Landscape Web UI by accessing the IP address of your HAProxy unit.
To find out the IP address of your HAProxy unit, run the following command:

```bash
juju status haproxy --format line | grep -v ^$ | awk '{print $3}' | head -1
```

### Task 3: Remove the Landscape Application Bundle together with the controller

Remove the Juju controller managing Openstack resources:

```bash
juju switch maas-controller
juju destroy-controller --destroy-all-models my-controller --no-prompt
```


# 13 Appendices !heading



## 13.1 Appendix A: Recover from total outage !heading

In cases of complete cluster failure, all nodes are down, when the
cluster comes us again, some services will be degraded. User input
is necessary.

Two services need manual intervention, the `mysql-innodb-cluster` charm
and the `vault` charm.


### 13.1.1 Recovering the DB

Check the the status of the DB charm. It should be in unhealthy state.

```bash
juju status mysql-innodb-cluster
# output
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


List the juju actions available for `mysql-innodb-cluster`. The action that
interests us is the `reboot-cluster-from-complete-outage` action.

```bash
juju actions mysql-innodb-cluster
```

`reboot-cluster-from-complete-outage` - In the case of a complete outage, reboot the cluster
from this instance's GTID superset.

Run this action on the leader unit of the charm.

```bash
juju run mysql-innodb-cluster/leader reboot-cluster-from-complete-outage --wait 15m
```

Wait a few minutes for this process to finish and check the cluster status again.

```bash
juju status mysql-innodb-cluster
```

### 13.1.2 Unseal Vault

The Vault charm needs to be unsealed after a complete cluster restart. Usually, Vault needs to be unsealed even after install,
but because we deployed Vault with the `totally-unsecure-auto-unlock` option, the charm unsealed itself automatically. This is
only done for testing purposes and not recommended in production.

Check the status of the Vault charm.

```bash
juju status vault
```

The Vault process inside the LXD container needs to be restarted in order to connect to the DB. Please note that the DB needs to be
active and running before doing this.

```bash
juju exec --unit vault/0 sudo systemctl status vault
```

```bash
juju exec --unit vault/0 sudo systemctl restart vault
```

Install the Vault client.

```bash
sudo snap install vault
```

Now it's time to get the unseal key. Usually, Vault requires at least 3 unseal keys, but because we used the 
`totally-unsecure-auto-unlock` (only for testing purposes), we only need one key. To get the key run the following command,
and look for `keys`:

```bash
juju exec --unit vault/0 leader-get
# output
keys: '["3291e16bcbfe08958043ae7963f9f1d12b0307819262c779600a72499dc80c65"]'
```

Unseal Vault using the keys from the file.

```bash
export VAULT_ADDR="http://$(juju exec --unit vault/leader unit-get private-address):8200"
```

```bash
vault operator unseal <unseal key 1>
```

Authorize the vault charm.

```bash
export VAULT_TOKEN=$(cat /home/ubuntu/vault-state.txt | grep "Initial Root Token" | awk '{print $4}')
```

```bash
CHARM_TOKEN=$(vault token create -ttl=10m | egrep "^token\s+" | awk '{print $2}')
```

```bash
juju run --wait 5m vault/leader authorize-charm token=$CHARM_TOKEN
```

Resolve the Vault charm if it is in error state.

```bash
juju resolved vault/0
```

Wait a few minutes for the charm to become active again.

Check the status of the charm.

```bash
juju status
# output
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


## 13.2 Appendix B: OpenStack Bundle File !heading

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


