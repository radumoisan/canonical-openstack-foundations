# 10. Work with OpenStack Storage

**Description:**

In this section, you work with Block storage and Object storage.

## :material-book-open-page-variant-outline: 10.1 Attach Volume Storage to a Cloud Workload Instance

**Description:**

In this exercise, you create a volume and attach it to an instance.

**10.1.1 Create a Storage Volume**

```bash
# Load the OpenStack student project environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Run the following `openstack` commands in the same shell session after sourcing `~/student_openrc`.

```bash
# Create a 5 GB volume named volume1 in the nova availability zone
openstack volume create volume1 --availability-zone nova --size 5 \
  --description 'StudentProject Volume 01'
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | attachments         | []                                   |
    | availability_zone   | nova                                 |
    | bootable            | false                                |
    | consistencygroup_id | None                                 |
    | created_at          | 2026-06-06T11:38:42.397074           |
    | description         | StudentProject Volume 01             |
    | encrypted           | False                                |
    | id                  | e218585b-c64f-45c8-83c0-3e4f948c709e |
    | multiattach         | False                                |
    | name                | volume1                              |
    | properties          |                                      |
    | replication_status  | None                                 |
    | size                | 5                                    |
    | snapshot_id         | None                                 |
    | source_volid        | None                                 |
    | status              | creating                             |
    | type                | __DEFAULT__                          |
    | updated_at          | None                                 |
    | user_id             | 89ed5796241e4dddb49afd47ed2d08f5     |
    +---------------------+--------------------------------------+
    ```

!!! note
    The volume name positional argument must appear before `--description`. Placing it after the description flag causes the name to be consumed as part of the description text.

```bash
# List volumes to confirm volume1 was created
openstack volume list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+---------+-----------+------+-------------+
    | ID                                   | Name    | Status    | Size | Attached to |
    +--------------------------------------+---------+-----------+------+-------------+
    | e218585b-c64f-45c8-83c0-3e4f948c709e | volume1 | available |    5 |             |
    +--------------------------------------+---------+-----------+------+-------------+
    ```

```bash
# Show full details of volume1
openstack volume show volume1
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +------------------------------+--------------------------------------+
    | Field                        | Value                                |
    +------------------------------+--------------------------------------+
    | attachments                  | []                                   |
    | availability_zone            | nova                                 |
    | bootable                     | false                                |
    | consistencygroup_id          | None                                 |
    | created_at                   | 2026-06-06T11:38:42.000000           |
    | description                  | StudentProject Volume 01             |
    | encrypted                    | False                                |
    | id                           | e218585b-c64f-45c8-83c0-3e4f948c709e |
    | multiattach                  | False                                |
    | name                         | volume1                              |
    | os-vol-tenant-attr:tenant_id | 98b0c6176739443d827d4c51f88afcbe     |
    | properties                   |                                      |
    | replication_status           | None                                 |
    | size                         | 5                                    |
    | snapshot_id                  | None                                 |
    | source_volid                 | None                                 |
    | status                       | available                            |
    | type                         | __DEFAULT__                          |
    | updated_at                   | 2026-06-06T11:39:06.000000           |
    | user_id                      | 89ed5796241e4dddb49afd47ed2d08f5     |
    +------------------------------+--------------------------------------+
    ```

**10.1.2 Attach a Volume to an Instance**

```bash
# Load the OpenStack student project environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Attach volume1 to the jammy1 instance at device /dev/vdb
openstack server add volume --device /dev/vdb jammy1 volume1
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | ID                    | e218585b-c64f-45c8-83c0-3e4f948c709e |
    | Server ID             | e0bc4a2e-389d-4a46-9fe3-4d923903e0e8 |
    | Volume ID             | e218585b-c64f-45c8-83c0-3e4f948c709e |
    | Device                | /dev/vdb                             |
    | Tag                   | None                                 |
    | Delete On Termination | False                                |
    +-----------------------+--------------------------------------+
    ```

```bash
# Verify the volume is attached to jammy1
openstack server show jammy1 -c volumes_attached -f value
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    [{'id': 'e218585b-c64f-45c8-83c0-3e4f948c709e', 'delete_on_termination': False}]
    ```

```bash
# Retrieve the key pair name used by the instance
openstack server show jammy1 -c key_name -f value
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    student-keypair
    ```

```bash
# Retrieve the IP addresses associated with the instance
openstack server show jammy1 -c addresses -f value
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    {'StudentProject_Network': ['10.20.30.162', '192.168.100.180']}
    ```

The `192.168.100.x` address is the floating IP.

**10.1.3 Check the Volume**

```bash
# SSH into the instance using the student key pair and the floating IP
ssh -i ~/.ssh/student-keypair.pem ubuntu@192.168.100.180
```

??? example "Expected result"
    ```bash
    Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-157-generic x86_64)
    ...
    ubuntu@jammy1:~$
    ```

```bash
# View the disks attached to the instance
sudo fdisk -l
```

??? example "Expected result"
    ```bash
    Disk /dev/vda: 5 GiB, 5368709120 bytes, 10485760 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: gpt
    Disk identifier: 9E2F366D-9C82-41E0-9E15-A9B5679F8E0F

    Device      Start      End  Sectors  Size Type
    /dev/vda1  227328 10485726 10258399  4.9G Linux filesystem
    /dev/vda14   2048    10239     8192    4M BIOS boot
    /dev/vda15  10240   227327   217088  106M EFI System

    Partition table entries are not in disk order.

    Disk /dev/vdb: 5 GiB, 5368709120 bytes, 10485760 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    ```

The `/dev/vdb` disk is the attached volume. Optionally, you can create partitions on the volume, format it with a filesystem, and mount it using either `parted` or `fdisk`.

```bash
# Exit the instance SSH session
exit
```

??? example "Expected result"
    ```bash
    Connection to 192.168.100.180 closed.
    ```

```bash
# List servers before cleanup
openstack server list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+--------+--------+------------------------------------------------------+-------+------------+
    | ID                                   | Name   | Status | Networks                                             | Image | Flavor     |
    +--------------------------------------+--------+--------+------------------------------------------------------+-------+------------+
    | e0bc4a2e-389d-4a46-9fe3-4d923903e0e8 | jammy1 | ACTIVE | StudentProject_Network=10.20.30.162, 192.168.100.180 | jammy | m1.smaller |
    +--------------------------------------+--------+--------+------------------------------------------------------+-------+------------+
    ```

```bash
# Delete the jammy1 instance
openstack server delete jammy1
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Wait for the volume to transition from in-use to available, then delete it
sleep 5
openstack volume delete volume1
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    The `sleep` allows the volume to transition from `in-use` to `available` after the instance is deleted. A volume cannot be deleted while its status is `in-use`.

## :material-book-open-page-variant-outline: 10.2 Upload Objects into Swift

**Description:**

In this exercise, you upload files as objects into Swift.

**10.2.1 Upload a File to Swift**

```bash
# Load the OpenStack administrator environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Source `admin_openrc` rather than the project-specific `.rc` file because the files are uploaded to the Admin project and then made publicly accessible to all tenants.

```bash
# Create a new Swift container named mydata
openstack container create mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------+-----------+-------------------------------------------------+
    | account | container | x-trans-id                                      |
    +---------+-----------+-------------------------------------------------+
    | v1      | mydata    | tx000001e89c361d2ce014d-006a240780-7218-default |
    +---------+-----------+-------------------------------------------------+
    ```

```bash
# List containers to confirm mydata was created
openstack container list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------+
    | Name   |
    +--------+
    | mydata |
    +--------+
    ```

```bash
# Show the container status and object count
openstack container show mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------+-------------------+
    | Field          | Value             |
    +----------------+-------------------+
    | account        | v1                |
    | bytes_used     | 0                 |
    | container      | mydata            |
    | object_count   | 0                 |
    | storage_policy | default-placement |
    +----------------+-------------------+
    ```

The `object_count` should be `0`.

```bash
# Create a directory for test files
mkdir ~/mydata
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Create two test files
echo "my file 1" > ~/mydata/myfile01.txt
echo "my file 2" > ~/mydata/myfile02.txt
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Change to the mydata directory
cd ~/mydata
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Upload all files in the current directory to the mydata container
openstack object create mydata *
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------+-----------+----------------------------------+
    | object       | container | etag                             |
    +--------------+-----------+----------------------------------+
    | myfile01.txt | mydata    | fb11eaef298d9c2ebcd571ac866068c3 |
    | myfile02.txt | mydata    | e791fc7ddba5b9f3e085528a4199a334 |
    +--------------+-----------+----------------------------------+
    ```

```bash
# Verify the container now shows two objects
openstack container show mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------+-------------------+
    | Field          | Value             |
    +----------------+-------------------+
    | account        | v1                |
    | bytes_used     | 20                |
    | container      | mydata            |
    | object_count   | 2                 |
    | storage_policy | default-placement |
    +----------------+-------------------+
    ```

```bash
# List the objects in the mydata container
openstack object list mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------+
    | Name         |
    +--------------+
    | myfile01.txt |
    | myfile02.txt |
    +--------------+
    ```

**10.2.2 Set ACLs on a Container**

!!! note
    The `swift` client from `python3-swiftclient` is used here because not all Swift ACL features are available in the unified `openstack` client. The package is pre-installed on the MAAS server.

```bash
# Show the current container status and ACL settings
swift stat mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
                          Account: v1
                        Container: mydata
                          Objects: 2
                            Bytes: 20
                         Read ACL:
                        Write ACL:
                          Sync To:
                         Sync Key:
                           Server: Ceph Object Gateway (squid)
                      X-Timestamp: 1780746113.32952
    X-Container-Bytes-Used-Actual: 8192
                 X-Storage-Policy: default-placement
                  X-Storage-Class: STANDARD
                    Last-Modified: Sat, 06 Jun 2026 11:41:53 GMT
                       X-Trans-Id: tx000005e470e419cd74c61-006a2407d0-7218-default
           X-Openstack-Request-Id: tx000005e470e419cd74c61-006a2407d0-7218-default
                    Accept-Ranges: bytes
                     Content-Type: text/plain; charset=utf-8
    ```

Both Read ACL and Write ACL are empty, meaning the container is private.

```bash
# Set a public Read ACL on the container
swift post mydata --read-acl ".r:*"
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Verify the Read ACL is now set
swift stat mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
                          Account: v1
                        Container: mydata
                          Objects: 2
                            Bytes: 20
                         Read ACL: .r:*
                        Write ACL:
                          Sync To:
                         Sync Key:
                           Server: Ceph Object Gateway (squid)
                      X-Timestamp: 1780746113.32952
    X-Container-Bytes-Used-Actual: 8192
                 X-Storage-Policy: default-placement
                  X-Storage-Class: STANDARD
                    Last-Modified: Sat, 06 Jun 2026 11:43:22 GMT
                       X-Trans-Id: tx0000067086cc9981c40ac-006a2407e4-7218-default
           X-Openstack-Request-Id: tx0000067086cc9981c40ac-006a2407e4-7218-default
                    Accept-Ranges: bytes
                     Content-Type: text/plain; charset=utf-8
    ```

The Read ACL now shows `.r:*`, making the container publicly readable.

## :material-book-open-page-variant-outline: 10.3 Download an Object from the Object Store

**Description:**

In this exercise, you download an object that was previously uploaded into Swift.

!!! note
    You should have uploaded the contents of the `~/mydata` directory to the Object Store container `mydata` before performing this exercise.

**10.3.1 Download an Object from the Object Store with the openstack client**

```bash
# Change to home directory and load the administrator environment
cd ~
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# List the objects in the mydata container
openstack object list mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------+
    | Name         |
    +--------------+
    | myfile01.txt |
    | myfile02.txt |
    +--------------+
    ```

```bash
# Download myfile01.txt from the object store to the current directory
openstack object save mydata myfile01.txt
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Verify the file was saved
ls -l ~/myfile01.txt
```

??? example "Expected result"
    ```bash
    -rw-rw-r-- 1 ubuntu ubuntu 10 Jun  6 11:43 /home/ubuntu/myfile01.txt
    ```

**10.3.2 Download an Object from the Object Store with wget**

```bash
# Load the OpenStack administrator environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Get the public endpoint URL for the object-store service
openstack endpoint list --service object-store --interface public -f value
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    393a8c74b7a94d63a0053163419b1054 RegionOne swift object-store True public https://192.168.100.43:443/swift/v1
    ```

```bash
# List the objects in the mydata container
openstack object list mydata
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------+
    | Name         |
    +--------------+
    | myfile01.txt |
    | myfile02.txt |
    +--------------+
    ```

```bash
# Download myfile02.txt via wget using the Swift public URL and the lab CA certificate
wget https://192.168.100.43/swift/v1/mydata/myfile02.txt \
  --ca-certificate=/home/ubuntu/snap/openstackclients/common/root-ca.crt
```

??? example "Expected result"
    ```bash
    --2026-06-06 11:45:29--  https://192.168.100.43/swift/v1/mydata/myfile02.txt
    Connecting to 192.168.100.43:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 10 [text/plain]
    Saving to: 'myfile02.txt'

         0K                                                       100% 6.56M=0s

    2026-06-06 11:45:29 (6.56 MB/s) - 'myfile02.txt' saved [10/10]
    ```

!!! note
    The Swift public endpoint URL format is `https://<swift-ip>/swift/v1`. The full object URL appends `/<container>/<object-name>` to this base. The `--ca-certificate` flag is required because the lab uses a self-signed CA.

```bash
# View the contents of the downloaded file
cat myfile02.txt
```

??? example "Expected result"
    ```bash
    my file 2
    ```

## :material-book-open-page-variant-outline: 10.4 Web UI Equivalents

This section provides a Web UI alternative to the validated CLI workflow above.
If you already completed the CLI steps, treat this section as optional.

!!! note
    Use the browser proxy path from Chapter 1 and the Horizon access details from Chapter 5 to reach the dashboard at `https://192.168.100.35/horizon`.

**10.4.1 Attach Volume Storage to a Cloud Workload Instance via the Web UI**

**10.4.1.1 Create a Storage Volume**

**To create a storage volume via the Web UI perform the following:**

1. Log into the OpenStack Dashboard as `student`.
2. From the panels on the left, select: `Project > Volumes > Volumes`.
3. Click `Create Volume`.
4. On the `Create Volume` screen, enter or select the following:
> `Volume Name`: **volume1**<br/>
> `Description`: **StudentProject Volume 01**<br/>
> `Volume Source`: **No source, empty volume**<br/>
> `Type`: **No volume type**<br/>
> `Size (GB)`: **5**<br/>
> `Availability Zone`: **nova**
5. Click `Create Volume`. You should see the new volume listed.

**10.4.1.2 Attach a Volume to an Instance**

**To attach a volume to an instance via the Web UI perform the following:**

1. Log into the OpenStack Dashboard as `student` and go to `Project > Volumes > Volumes`.
2. Next to the `volume1` volume, in the Actions column, from the `Edit Volume` drop-down list, select `Manage Attachments`.
3. On the `Manage Volume Attachments` screen, from the `Attach to Instance` drop-down list, select one of the running instances.
4. Click `Attach Volume`.
5. You should see the instance name listed under the `Attached To` column.
6. From the panels on the left, select: `Project > Compute > Instances`.
7. Click on the instance name of the instance you attached the volume to.
8. On the `Instances / VM_NAME` screen under `Volumes Attached`, you should see the volume listed.
9. Note the key pair used by the instance. This will be located under the `Metadata` section and listed as `Key Name`.
10. Also note the instance's floating IP. This should be the second IP address listed in the `IP Addresses` section adjacent to the `Network` name.
11. We will refer to these as `INSTANCE_KEYPAIR` and `INSTANCE_FLOATING_IP`.

**10.4.2 Upload Objects into Swift via the Web UI**

**10.4.2.1 Upload a File to Swift**

**To upload files to Swift via the Web UI perform the following:**

1. Log into the OpenStack Dashboard as `admin`.
2. From the panels on the left, select: `Project > Object Store > Containers`.
3. In the `Containers` pane, click `+ Container`.
4. On the `Create Container` screen, enter or select the following:
> `Container Name`: **mydata**<br/>
> `Public Access`: **NotPublic** (selected)
5. Click `Submit`.
6. In the `Containers` pane, click on the container `mydata`.
7. In the `Containers` pane, click on the `Upload File` icon (located next to the trashcan on the right side of the pane).
8. On the `Upload File To: mydata` screen, click `Browse` next to `File`.
9. Select a small file from your local (student machine) file system and click `Open`.
10. Click `Upload File`. You should see the file listed.

**10.4.2.2 Set ACLs on a Container**

**To set ACLs on a container via the Web UI perform the following:**

1. Log into the OpenStack Dashboard as `admin`.
2. From the panels on the left, select: `Project > Object Store > Containers`.
3. In the `Containers` pane, click on the container `mydata`.
4. In the `mydata` info box, check the `Public Access` box.
5. You should see a link named `link` next to the checked `Public Access` box.

**10.4.2.3 Download an Object from the Object Store via the Web UI**

1. Log into the OpenStack Dashboard as `admin`.
2. From the panels on the left, select: `Project > Object Store > Containers`.
3. In the `Containers` pane, click on the container `mydata`.
4. In the `mydata` files box, click `Download` to the right of the file you wish to save locally.

!!! note
    This method saves the file to the local (student) machine and not to the MAAS server.
