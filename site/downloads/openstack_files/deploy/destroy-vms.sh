#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Destroy Juju VM
virsh destroy os-juju01
virsh undefine os-juju01
rm -f ~/os-juju01.xml
rm -f /home/VMs/juju01/juju01d1.qcow2

# Destroy Compute VMs
for i in `seq 1 4`; do
  vm=compute0${i}
  virsh destroy os-${vm}
  virsh undefine os-${vm}
  rm -f ~/os-${vm}.xml
  rm -f /home/VMs/${vm}/${vm}d1.qcow2
  rm -f /home/VMs/${vm}/${vm}d2.qcow2
done