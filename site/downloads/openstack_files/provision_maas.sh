#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LC_ALL=C
ZONE=$1

echo "Installing updates"
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils libvirt-daemon-system pv qemu-utils sshpass virtinst

sudo usermod -aG kvm ubuntu
sudo usermod -aG libvirt ubuntu

echo "Creating new KVM network"
sudo virsh net-destroy default
sudo virsh net-undefine default
sudo virsh net-define /home/ubuntu/deploy/cloud.xml
sudo virsh net-start cloud
sudo virsh net-autostart cloud

echo "Downloading the MAAS image"
max_attempts=5
attempt=1
download_timeout=300  # 5 minutes

while [ $attempt -le $max_attempts ]; do
    echo "Download attempt $attempt of $max_attempts..."
    if sudo timeout $download_timeout wget -q --timeout 30 -O /var/lib/libvirt/images/maas.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img; then
        # Check if file was actually downloaded
        if [ -s /var/lib/libvirt/images/maas.img ]; then
            echo "Download successful!"
            break
        else
            echo "Download appeared successful but file is empty"
        fi
    else
        echo "Download attempt $attempt failed with status $?"
        if [ $attempt -eq $max_attempts ]; then
            echo "All download attempts failed. Exiting."
            exit 1
        fi
        echo "Waiting 30 seconds before retrying..."
        sleep 30
        attempt=$((attempt + 1))
    fi
done

echo "Resizing image"
sudo qemu-img resize /var/lib/libvirt/images/maas.img +35G
echo "Copying cloud-init.iso"
sudo cp /home/ubuntu/deploy/cloud-init.iso /var/lib/libvirt/images/
echo "Changing ownership of new files"
sudo bash -c 'chown libvirt-qemu:kvm /var/lib/libvirt/images/*'

sudo virt-install  \
    --name maas  \
    --ram 4096  \
    --vcpus 2  \
    --disk path=/var/lib/libvirt/images/maas.img,format=qcow2,bus=virtio  \
    --disk path=/var/lib/libvirt/images/cloud-init.iso,device=cdrom  \
    --os-variant ubuntu22.04  \
    --network bridge=virbr1,model=virtio  \
    --graphics none  \
    --console pty,target_type=serial  \
    --import  \
    --noautoconsole


echo "Starting the MAAS machine on boot"
sudo virsh autostart maas
echo "MAAS machine started"

# echo "Waiting for the MAAS machine to come up..."
# wait_for_ssh() {
#     local host=$1
#     local user=$2
#     local password=$3
#     local max_attempts=30
#     local wait_seconds=10

#     echo "Waiting for SSH to become available on $host..."
#     for ((i=1; i<=max_attempts; i++)); do
#         if sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$host" exit 2>/dev/null; then
#             echo "SSH is now available!"
#             return 0
#         fi
#         echo "Attempt $i/$max_attempts - SSH not yet available, waiting $wait_seconds seconds..."
#         sleep $wait_seconds
#     done
#     echo "Failed to establish SSH connection after $max_attempts attempts"
#     exit 1
# }

# wait_for_ssh "192.168.100.3" "ubuntu" "ubuntu"

# sshpass -p ubuntu ssh -o StrictHostKeyChecking=no ubuntu@192.168.100.3 'sudo apt-get update'
# sshpass -p ubuntu ssh -o StrictHostKeyChecking=no ubuntu@192.168.100.3 'sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade'
# sshpass -p ubuntu ssh -o StrictHostKeyChecking=no ubuntu@192.168.100.3 'sudo DEBIAN_FRONTEND=noninteractive apt-get -y install -y vim jq qemu-utils python3-swiftclient libvirt-clients'
# sshpass -p ubuntu ssh -o StrictHostKeyChecking=no ubuntu@192.168.100.3 'sudo reboot'

# echo "MAAS VM created successfully! Rebooting..."

# sudo reboot