# 7. Work with Cloud Images

**Description:**

In this section, you work with the OpenStack Glance service, using it to store
and manage cloud images.

## :material-book-open-page-variant-outline: 7.1 Upload Images into Glance

**Description:**

In this exercise, you upload a cloud image to Glance. You then update the image
by adding custom properties to the image.

**7.1.1 Download the Cloud Image**

```bash
# Create a directory to store the cloud images
mkdir ~/cloud_images
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Change into the cloud image working directory
cd ~/cloud_images
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Download the Ubuntu Jammy minimal cloud image
wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
```

??? example "Expected result"
    ```bash
    --2026-06-06 10:40:24--  https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
    Resolving cloud-images.ubuntu.com... 185.125.190.40, 185.125.190.39, ...
    Connecting to cloud-images.ubuntu.com|185.125.190.40|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 308800512 (295M) [application/x-qemu-disk]
    Saving to: 'ubuntu-22.04-minimal-cloudimg-amd64.img'

         0K .......... .......... .......... .......... ..........  0% 10.2M 29s
       ...
    301550K .......... ...                                        100% 85.2M=2.2s

    2026-06-06 10:40:26 (134 MB/s) - 'ubuntu-22.04-minimal-cloudimg-amd64.img' saved [308800512/308800512]
    ```

```bash
# Check the file type of the downloaded cloud image
file ubuntu-22.04-minimal-cloudimg-amd64.img
```

??? example "Expected result"
    ```bash
    ubuntu-22.04-minimal-cloudimg-amd64.img: QEMU QCOW2 Image (v2), 2361393152 bytes
    ```

```bash
# Inspect the downloaded QCOW2 image
qemu-img info ubuntu-22.04-minimal-cloudimg-amd64.img
```

??? example "Expected result"
    ```bash
    image: ubuntu-22.04-minimal-cloudimg-amd64.img
    file format: qcow2
    virtual size: 2.2 GiB (2361393152 bytes)
    disk size: 294 MiB
    cluster_size: 65536
    Format specific information:
        compat: 0.10
        compression type: zlib
        refcount bits: 16
    ```

```bash
# Convert the image to raw format for use with the Ceph-backed lab cloud
qemu-img convert \
        -f qcow2 \
        -O raw \
        ubuntu-22.04-minimal-cloudimg-amd64.img \
        ubuntu-jammy.img
```

??? example "Expected result"
    ```bash
    No output.
    ```

!!! note
    Raw images are preferred in this lab because Glance stores images on a Ceph backend.

```bash
# Inspect the converted raw image
qemu-img info ubuntu-jammy.img
```

??? example "Expected result"
    ```bash
    image: ubuntu-jammy.img
    file format: raw
    virtual size: 2.2 GiB (2361393152 bytes)
    disk size: 906 MiB
    ```

!!! note
    Note the `virtual size`. You cannot launch workload instances from this image with a flavor whose root disk is smaller than `2.2 GiB`.

**7.1.2 Upload the Cloud Image into Glance**

```bash
# Load the OpenStack administrator environment into the current shell
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    Run the following `openstack` commands in the same shell session after sourcing `~/admin_openrc`.

```bash
# List the images currently available in Glance
openstack image list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    At this stage, no images are listed yet.

```bash
# Upload the raw Jammy image into Glance as a public image
openstack image create \
        --public \
        --min-disk 3 \
        --container-format bare \
        --disk-format raw \
        --property architecture=x86_64 \
        --file ~/cloud_images/ubuntu-jammy.img \
        --progress \
        jammy
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field            | Value                                                                                                                                                                            |
    +------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | container_format | bare                                                                                                                                                                             |
    | created_at       | 2026-06-06T10:41:45Z                                                                                                                                                             |
    | disk_format      | raw                                                                                                                                                                              |
    | file             | /v2/images/0c483320-4a39-43e6-a11a-d7f39bef94e8/file                                                                                                                             |
    | id               | 0c483320-4a39-43e6-a11a-d7f39bef94e8                                                                                                                                             |
    | min_disk         | 3                                                                                                                                                                                |
    | min_ram          | 0                                                                                                                                                                                |
    | name             | jammy                                                                                                                                                                            |
    | owner            | 045c13c72f32404ebf6c5ed6b2cebbf2                                                                                                                                                 |
    | properties       | architecture='x86_64', locations='[]', os_hidden='False', owner_specified.openstack.md5='', owner_specified.openstack.object='images/jammy', owner_specified.openstack.sha256='' |
    | protected        | False                                                                                                                                                                            |
    | schema           | /v2/schemas/image                                                                                                                                                                |
    | status           | queued                                                                                                                                                                           |
    | tags             |                                                                                                                                                                                  |
    | updated_at       | 2026-06-06T10:41:45Z                                                                                                                                                             |
    | visibility       | public                                                                                                                                                                           |
    +------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    ```

!!! note
    In this environment, `--progress` did not display a visible progress bar. The image initially appeared with status `queued` and then reached `active` a few seconds later.

```bash
# Confirm that the new image is now available in Glance
openstack image list
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +--------------------------------------+-------+--------+
    | ID                                   | Name  | Status |
    +--------------------------------------+-------+--------+
    | 0c483320-4a39-43e6-a11a-d7f39bef94e8 | jammy | active |
    +--------------------------------------+-------+--------+
    ```

```bash
# Show the full details of the uploaded image
openstack image show jammy
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field            | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
    +------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | checksum         | f01c0ab8e64eb46abf588dc8970abf1d                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
    | container_format | bare                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
    | created_at       | 2026-06-06T10:41:45Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
    | disk_format      | raw                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
    | file             | /v2/images/0c483320-4a39-43e6-a11a-d7f39bef94e8/file                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
    | id               | 0c483320-4a39-43e6-a11a-d7f39bef94e8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
    | min_disk         | 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
    | min_ram          | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
    | name             | jammy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
    | owner            | 045c13c72f32404ebf6c5ed6b2cebbf2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
    | properties       | architecture='x86_64', direct_url='rbd://9fde5db8-60fe-11f1-9d9b-818b9e2edeef/glance/0c483320-4a39-43e6-a11a-d7f39bef94e8/snap', locations='[{'url': 'rbd://9fde5db8-60fe-11f1-9d9b-818b9e2edeef/glance/0c483320-4a39-43e6-a11a-d7f39bef94e8/snap', 'metadata': {'store': 'ceph'}}]', os_hash_algo='sha512', os_hash_value='3bf7f7e6ea99e04c621328f89e76d9cc21d1b1f6bf60cd15c11d62dcb05c8c1e7c9738fc8de606e685fc027b2e046683ee15ad5509c14691e71e4f2d620db8cf', os_hidden='False', owner_specified.openstack.md5='', owner_specified.openstack.object='images/jammy', owner_specified.openstack.sha256='', stores='ceph' |
    | protected        | False                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
    | schema           | /v2/schemas/image                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
    | size             | 2361393152                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
    | status           | active                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
    | tags             |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
    | updated_at       | 2026-06-06T10:42:37Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
    | virtual_size     | 2361393152                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
    | visibility       | public                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
    +------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    ```

## :material-book-open-page-variant-outline: 7.2 Web UI Equivalents

This section provides a Web UI alternative to the validated CLI workflow above.
If you already uploaded the image with the CLI, treat this section as optional.

!!! note
    Use the browser proxy path from Chapter 1 and the Horizon access details from Chapter 5 to reach the dashboard at `https://192.168.100.35/horizon`.

**7.2.1 Upload the Cloud Image into Glance via the Web UI**

**To upload the cloud image via the Web UI perform the following:**

1. Log into the dashboard as the `admin` user.
2. From the list of tabs on the left select `Admin > Compute > Images`.
3. Click `Create Image`.
4. On the `Create An Image` screen, enter or select the following values and leave all unspecified values at their defaults:
> `Image Name`: **jammy**<br/>
> `Description`: **ubuntu 22.04**<br/>
> `Source Type`: **File** and then `Browse`<br/>
> `Format`: **RAW**<br/>
> `Architecture`: **x86_64**<br/>
> `Minimum Disk (GB)`: **3**<br/>
> `Minimum RAM (MB)`: **leave blank**<br/>
> `Visibility`: **Public**<br/>
> `Protected`: **no**
5. Click `Create Image`.
6. To update the metadata associated with the image, select `Admin > Compute > Images`.
7. Click the `Launch` drop-down to the right of the image name and select `Update Metadata`.
8. On the `Update Image Metadata` page, locate `hw_disk_bus` under `Available Metadata`.
9. Click the `+` next to `hw_disk_bus`. The metadata key should populate the `Existing Metadata` section.
10. In the `Existing Metadata` section, locate the newly added metadata key and enter `virtio` in the input block to the right of it.
11. Click `Save`.
