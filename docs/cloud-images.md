# 7. Work with Cloud Images

**Description:**

In this section, you work with the OpenStack Glance service, using it to store and
manage cloud images.

## 7.1 Upload Images into Glance

**Description:**

In this exercise, you upload a cloud image to Glance. You then update the image by
adding custom properties to the image.

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
