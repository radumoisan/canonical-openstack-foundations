# 9. Work with Cloud Workload Instances

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
