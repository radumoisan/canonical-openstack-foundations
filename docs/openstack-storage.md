# 10. Work with OpenStack Storage

**Description:**

In this section, you work with Block storage and Object storage.

## :material-book-open-page-variant-outline: 10.1 Attach Volume Storage to a Cloud Workload Instance

**Description:**

In this exercise, you create a volume and attach it to an instance.

### :material-book-open-page-variant-outline: Task 1: Create a Storage Volume

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

### :material-book-open-page-variant-outline: Task 2: Attach a Volume to an Instance

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



### :material-book-open-page-variant-outline: Task 3: Check the Volume

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


## :material-book-open-page-variant-outline: 10.2 Upload Objects into Swift

**Description:**

In this exercise, you upload files as objects into Swift.

### :material-book-open-page-variant-outline: Task 1: Upload a File to Swift

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



### :material-book-open-page-variant-outline: Task 2: Set ACLs on a Container

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




## :material-book-open-page-variant-outline: 10.3 Download an Object from the Object Store

**Description:**

In this exercise, you download an object that was previously uploaded into Swift.

**Note:** You should have uploaded the contents of the `~/mydata` directory to the
Object Store container `mydata` before performing this exercise.


### :material-book-open-page-variant-outline: Task 1: Download an Object from the Object Store with the openstack client

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


### :material-book-open-page-variant-outline: Task 2: Download an Object from the Object Store with wget

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


## :material-book-open-page-variant-outline: 10.4 WEB UI

## :material-book-open-page-variant-outline: 10.4.1 Attach Volume Storage to a Cloud Workload Instance

### :material-book-open-page-variant-outline: Task 1: Create a Storage Volume

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


### :material-book-open-page-variant-outline: Task 2: Attach a Volume to an Instance

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




## :material-book-open-page-variant-outline: 10.4.2 Upload Objects into Swift

**Description:**

### :material-book-open-page-variant-outline: Task 1: Upload a File to Swift

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


### :material-book-open-page-variant-outline: Task 2: Set ACLs on a Container

**To set ACLs on a container via the WebUI perform the following:**

1. To perform this task via the OpenStack Dashboard, do the following:
2. Log into the OpenStack Dashboard as `admin`.
3. From the panels on the left, select: `Project > Object Store > Containers`.
4. In the `Containers` pane, click on the container `mydata`.
5. In the `mydata` info box, enter/select the following:
> `Public Access`: **(checked)**
6. You should see a link named `link` next to the checked `Public Access` box.

### :material-book-open-page-variant-outline: Task 3: Download an Object from the Object Store via the WebUI

1. Log into the OpenStack Dashboard as `admin`.
2. From the panels on the left, select: `Project > Object Store > Containers`.
3. In the `Containers` pane, click on the container `mydata`.
4. In the `mydata` files box, click `Download` to the right of the file you wish to save locally.

> This method will save the file to the local (student) machine and not to the MAAS server.
