# 6. Work with Software Defined Networks

**Description:**

In this section, you manage the software defined networks in an OpenStack cloud
using Neutron.


## :material-book-open-page-variant-outline: 6.1 Define the OpenStack External Network

**Description:**

In this exercise, you create the external network for the OpenStack cloud.


**6.1.1 Define the OpenStack External Network**

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

## :material-book-open-page-variant-outline: 6.2 WEB UI

## :material-book-open-page-variant-outline: 6.2.1 Define the OpenStack External Network via WebUI

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

