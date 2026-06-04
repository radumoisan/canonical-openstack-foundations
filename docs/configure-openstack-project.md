# 8. Configure an OpenStack Project

**Description:**

In this section you create and configure a project in OpenStack.

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


### Task 1: Define a Rule to Allow Incoming and Outgoing SSH


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

### Task 1: Modify a Project's Quotas

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

### Task 1: Define a Rule to Allow Incoming and Outgoing SSH

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

### Task 1: Modify a Project's Quotas

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

### Task 1: Allocate a Floating IP to a Project

**To allocate a floating IP to a project via the WebUI perform the following:**

1. In a web browser, log into the Dashboard as `student`.
2. From the panels on the left select: `Project > Network > Floating IPs`.
3. Click `Allocate IP To Project`.
4. On the `Allocate Floating IP` screen, from the Pool drop-down list, select: `Public_Network`.
5. Click `Allocate IP`. You should see that an IP address has been allocated to the project.
