#!/bin/bash
CPUOPTS="--cpu host"
GRAPHICS="--graphics vnc --video=cirrus"
CONTROLLER="--controller scsi,model=virtio-scsi,index=0"
DISKOPTS="format=raw,bus=virtio,cache=none,io=native"
export CPUOPTS GRAPHICS CONTROLLER DISKOPTS

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Juju VM
mkdir -p /home/VMs/juju01
qemu-img create -f raw /home/VMs/juju01/juju01d1.img 40G
virt-install --noautoconsole --print-xml --boot network,hd,menu=on \
  $GRAPHICS $CONTROLLER --name os-juju01 --ram 2048 --vcpus 2 $CPUOPTS\
  --disk path=/home/VMs/juju01/juju01d1.img,size=40,$DISKOPTS \
  --network=network=cloud,mac=52:54:00:63:6e:6a,model=e1000 \
  --network=network=cloud,mac=52:54:00:63:6e:6b,model=e1000 \
  --osinfo=ubuntujammy >> ~/os-juju01.xml
virsh define ~/os-juju01.xml
virsh autostart os-juju01

# Compute VMs
macs=( 0 a b c )
for i in `seq 1 4`; do
  vm=compute0${i}
  m=${macs[i - 1]}
  mac1="52:54:00:63:${m}e:${m}c"
  mac2="52:54:00:63:${m}e:${m}d"

  mkdir -p /home/VMs/${vm}
  qemu-img create -f raw /home/VMs/${vm}/${vm}d1.img 60G
  qemu-img create -f raw /home/VMs/${vm}/${vm}d2.img 20G
  virt-install --noautoconsole --print-xml --boot network,hd,menu=on \
    $GRAPHICS $CONTROLLER --name os-${vm} --ram 13312 --vcpus 4 $CPUOPTS \
    --disk path=/home/VMs/${vm}/${vm}d1.img,size=60,$DISKOPTS \
    --disk path=/home/VMs/${vm}/${vm}d2.img,size=20,$DISKOPTS \
    --network=network=cloud,mac=${mac1},model=e1000 \
    --network=network=cloud,mac=${mac2},model=e1000 \
    --osinfo=ubuntujammy >> ~/os-${vm}.xml
  virsh define ~/os-${vm}.xml
  virsh autostart os-${vm}
done
