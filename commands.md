# Successful Command Reference

These are exact successful commands preserved as execution references for this lab environment.

## Canonical SSH access

Use this command to reach the student host:

```bash
ssh ubuntu@34.40.48.14
```

Use this pattern to run commands on the MAAS VM from the student host:

```bash
ssh ubuntu@34.40.48.14 'ssh ubuntu@192.168.100.3 "<command>"'
```

Use this command to validate the Chapter 1 SOCKS tunnel without leaving the
terminal session attached:

```bash
ssh -fN -D 9999 -i ~/.ssh/id_ed25519 -o BatchMode=yes -o ExitOnForwardFailure=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new ubuntu@34.40.48.14
```

## MAAS VM readiness and resize

```bash
ssh ubuntu@34.40.48.14 "ssh -i /home/ubuntu/.ssh/id_rsa -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa ubuntu@192.168.100.3 'hostname; uptime; df -h /; lsblk; sudo growpart --help >/dev/null 2>&1; echo growpart:$?'"
```

```bash
ssh ubuntu@34.40.48.14 'sudo qemu-img info /var/lib/libvirt/images/maas.img'
```

```bash
ssh ubuntu@34.40.48.14 'sudo virsh shutdown maas; for i in $(seq 1 30); do state=$(sudo virsh domstate maas); [ "$state" = "shut off" ] && break; sleep 2; done; state=$(sudo virsh domstate maas); if [ "$state" != "shut off" ]; then sudo virsh destroy maas; fi; sudo virsh domstate maas'
```

```bash
ssh ubuntu@34.40.48.14 'sudo qemu-img resize /var/lib/libvirt/images/maas.img +35G && sudo virsh start maas'
```

```bash
ssh ubuntu@34.40.48.14 'sudo qemu-img info -U /var/lib/libvirt/images/maas.img'
```

## Chapter 2 clean validation commands

```bash
ssh ubuntu@34.40.48.14 'sudo bash /home/ubuntu/provision_maas.sh europe-west3-a'
```

```bash
ssh ubuntu@34.40.48.14 'ssh -i /home/ubuntu/.ssh/id_rsa -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa ubuntu@192.168.100.3 "hostname"'
```

```bash
ssh ubuntu@34.40.48.14 'scp -r /home/ubuntu/os_files ubuntu@192.168.100.3:~'
```

```bash
ssh ubuntu@34.40.48.14 "ssh -i /home/ubuntu/.ssh/id_rsa -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa ubuntu@192.168.100.3 'sudo apt-get -f install -y && sudo apt-get install -y jq'"
```

```bash
ssh ubuntu@34.40.48.14 'sudo bash ~/deploy/create-vms.sh'
```

```bash
ssh ubuntu@34.40.48.14 'for vm in os-juju01 os-compute01 os-compute02 os-compute03 os-compute04; do sudo virsh start "$vm" || true; done'
```

```bash
ssh ubuntu@34.40.48.14 "ssh -i /home/ubuntu/.ssh/id_rsa -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa ubuntu@192.168.100.3 'maas myprofile machines add-chassis chassis_type=virsh hostname=qemu+ssh://ubuntu@192.168.100.1/system prefix_filter=\"os-\"'"
```

```bash
ssh ubuntu@34.40.48.14 "ssh -i /home/ubuntu/.ssh/id_rsa -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa ubuntu@192.168.100.3 'maas myprofile machines accept-all'"
```

```bash
ssh ubuntu@34.40.48.14 "ssh ubuntu@192.168.100.3 'maas myprofile machines read | jq -r \".[] | select(.hostname==\\\"os-juju01\\\" or .hostname==\\\"os-compute01\\\" or .hostname==\\\"os-compute02\\\" or .hostname==\\\"os-compute03\\\" or .hostname==\\\"os-compute04\\\") | \\\"\\(.hostname) \\(.status_name) \\(.system_id)\\\"\"'"
```

## Historical successful commands

The following commands succeeded during live validation and are preserved exactly as executed.

```bash
ssh ubuntu@34.159.9.11 'scp -r /home/ubuntu/os_files 192.168.100.3:~'
```

```bash
ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ubuntu@34.159.9.11 "ssh -o StrictHostKeyChecking=no ubuntu@192.168.100.3 'sudo snap install maas --channel=3.4'"
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo snap install maas-test-db --channel=3.4"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "echo | sudo maas init region+rack --database-uri maas-test-db:///"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo maas createadmin --username=admin --password=ubuntu --email=admin@example.com"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo maas apikey --username=admin > ~/maas-apikey"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas login myprofile http://192.168.100.3:5240/MAAS - < ~/maas-apikey"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas list"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile boot-source-selections create 1 os=\"ubuntu\" release=\"jammy\" arches=\"amd64\" subarches=\"*\" labels=\"*\""'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile boot-resources import"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "ssh-keygen -t rsa -N \"\" -q -f ~/.ssh/id_rsa"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile sshkeys create key=\"\`cat ~/.ssh/id_rsa.pub\`\""'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "FABRIC_ID=\`maas myprofile fabrics read | jq \".[0].id\"\`"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "FABRIC_ID=\`maas myprofile fabrics read | jq \".[0].id\"\`; VLAN_ID=\`maas myprofile vlans read \$FABRIC_ID | jq \".[0].vid\"\`"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "RACK_ID=\`maas myprofile rack-controllers read | jq -r \".[0].system_id\"\`"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile ipranges create type=dynamic start_ip=192.168.100.200 end_ip=192.168.100.254"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "FABRIC_ID=\`maas myprofile fabrics read | jq \".[0].id\"\`; VLAN_ID=\`maas myprofile vlans read \$FABRIC_ID | jq \".[0].vid\"\`; RACK_ID=\`maas myprofile rack-controllers read | jq -r \".[0].system_id\"\`; maas myprofile vlan update \$FABRIC_ID \$VLAN_ID primary_rack=\$RACK_ID dhcp_on=true mtu=1400"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile ipranges create type=reserved start_ip=192.168.100.1 end_ip=192.168.100.9"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile ipranges create type=reserved start_ip=192.168.100.150 end_ip=192.168.100.199"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile maas set-config name=upstream_dns value=\"8.8.8.8\""'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "maas myprofile maas set-config name=kernel_opts value=\"net.ifnames=0\""'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/00-installer-config.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo cat /etc/netplan/00-installer-config.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat <<'"'"'EOF'"'"' | sudo tee /etc/netplan/00-installer-config.yaml >/dev/null
network:
  version: 2
  ethernets:
    enp1s0:
      renderer: networkd
      addresses:
      - 192.168.100.3/24
      nameservers:
        addresses:
        - 192.168.100.3
        - 8.8.8.8
        search:
        - maas
      routes:
      - to: default
        via: 192.168.100.1
EOF"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo netplan apply"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "resolvectl status"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo snap install juju --channel=3.6/stable --devmode"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat ~/os_files/maas.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju add-cloud maas ~/os_files/maas.yaml --client"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju list-clouds"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat ~/maas-apikey"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat > ~/.local/share/juju/credentials.yaml <<EOF
credentials:
  maas:
    admin:
      auth-type: oauth1
      maas-oauth: \$(cat ~/maas-apikey)
EOF"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat ~/.local/share/juju/credentials.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju list-credentials"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju bootstrap --config default-base=\"ubuntu@22.04\" --bootstrap-constraints=\"mem=2G cores=1\" --constraints=\"mem=2G tags=juju\" maas maas-controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju switch controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju deploy juju-dashboard dashboard --to=lxd:0"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju integrate dashboard controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju expose dashboard"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m controller dashboard"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju show-unit dashboard/0 --format yaml | grep public-address | cut -f 2 -d \":\" | awk '\''{print $1}'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju models"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju ssh -m controller 0 -- hostname"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju scp -m controller /etc/services 0:/tmp"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju ssh -m controller 0 -- ls -al /tmp"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju ssh -m controller 0 -- cat /tmp/services"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju controllers"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju bootstrap --config default-base=\"ubuntu@22.04\" --bootstrap-constraints=\"mem=2G cores=1\" --constraints=\"mem=2G tags=juju\" maas maas-controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju models"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju add-model landscape"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju model-config -m landscape default-base=ubuntu@22.04"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju model-config default-base"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju deploy landscape-scalable"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status --relations"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status haproxy"'
```

```bash
for i in $(seq 1 30); do echo "=== Poll $i ==="; ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status --format short 2>&1"'; sleep 30; done
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju destroy-model --no-prompt landscape"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju destroy-controller maas-controller --no-prompt"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju switch controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju deploy juju-dashboard dashboard --to=lxd:0"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju integrate dashboard controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju expose dashboard"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m controller dashboard"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju dashboard --browser=false"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "for h in os-compute01 os-compute02 os-compute03 os-compute04 os-juju01; do SYSTEM_ID=\$(maas myprofile nodes read | jq -r \".[] | select(.hostname == \\\"\$h\\\") | .system_id\"); maas myprofile tag update-nodes juju add=\$SYSTEM_ID; done"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju bootstrap --config default-base=\"ubuntu@22.04\" --bootstrap-constraints=\"mem=2G cores=1\" --constraints=\"mem=2G tags=juju\" maas maas-controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju add-model uos"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju model-config -m uos default-base=ubuntu@22.04"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "head -50 /home/ubuntu/os_files/openstack-bundle.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju deploy /home/ubuntu/os_files/openstack-bundle.yaml"'
```

```bash
for i in $(seq 1 60); do echo "=== Poll $i at $(date) ==="; ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status --format short 2>&1"'; sleep 60; done
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "for i in 0 1 2 3; do echo \"--- Machine \$i ---\"; juju ssh \$i -- sudo sysctl kernel.softlockup_panic=0; juju ssh \$i -- sudo sysctl kernel.hardlockup_panic=0; juju ssh \$i -- sudo systemctl disable --now apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service; done"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju ssh ceph-mon/0 -- sudo ceph health detail"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju ssh ceph-mon/0 -- sudo ceph -s"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status openstack-dashboard"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "sudo snap install openstackclients --channel=2024.1/stable --devmode"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cp os_files/admin_openrc* ~/"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat ~/admin_openrc"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat ~/admin_openrcv3_project"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "source ~/admin_openrc && openstack catalog list"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "source ~/admin_openrc && openstack endpoint list"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "curl -s -o /dev/null -w \"%{http_code}\" http://192.168.100.35/horizon"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "for ((i=0;i<4;i++)); do juju ssh \$i sudo sysctl kernel.softlockup_panic=0; done"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "for ((i=0;i<4;i++)); do juju ssh \$i sudo sysctl kernel.hardlockup_panic=0; done"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "for ((i=0;i<4;i++)); do juju ssh \$i sudo systemctl disable --now apt-daily{,-upgrade}.{timer,service}; done"'
```

```bash
ssh ubuntu@34.159.9.11 << 'ENDSSH'
ssh ubuntu@192.168.100.3 << 'ENDMAAS'
for ((i=0;i<4;i++)); do
  juju ssh $i sudo sed -i '/Update-Package-Lists/s/"1"/"0"/' /etc/apt/apt.conf.d/*
done
ENDMAAS
ENDSSH
```

```bash
ssh ubuntu@34.159.9.11 << 'ENDSSH'
ssh ubuntu@192.168.100.3 << 'ENDMAAS'
for ((i=0;i<4;i++)); do
  juju ssh $i sudo sed -i '/Unattended-Upgrade/s/"1"/"0"/' /etc/apt/apt.conf.d/*
done
ENDMAAS
ENDSSH
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && env | grep OS_'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack network create Public_Network --external --provider-physical-network physnet1 --provider-network-type flat --mtu 1300'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack network list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack network show Public_Network'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack subnet create --ip-version 4 --allocation-pool start=192.168.100.150,end=192.168.100.199 --gateway=192.168.100.1 --no-dhcp --network Public_Network --subnet-range 192.168.100.0/24 Public_Subnet'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack subnet list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack subnet show Public_Subnet'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "curl -s -o /dev/null -w \"%{http_code}\" http://192.168.100.35/horizon"'
```

## Chapter 7 - Cloud Images

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "mkdir ~/cloud_images"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cd ~/cloud_images && wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "file ~/cloud_images/ubuntu-22.04-minimal-cloudimg-amd64.img"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "qemu-img info ~/cloud_images/ubuntu-22.04-minimal-cloudimg-amd64.img"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cd ~/cloud_images && qemu-img convert -f qcow2 -O raw ubuntu-22.04-minimal-cloudimg-amd64.img ubuntu-jammy.img"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "qemu-img info ~/cloud_images/ubuntu-jammy.img"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && echo SOURCED_OK'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack image list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack image create --public --min-disk 3 --container-format bare --disk-format raw --property architecture=x86_64 --file ~/cloud_images/ubuntu-jammy.img --progress \"jammy\"'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack image list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack image show jammy'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'scp ~/CentOS-Stream-GenericCloud-10-latest.x86_64.img ubuntu@192.168.100.3:~/'
```

```bash
ssh ubuntu@34.159.9.11 "ssh ubuntu@192.168.100.3 'source ~/admin_openrc && openstack image create --disk-format raw --container-format bare --public --property architecture=x86_64 --file ~/CentOS-Stream-GenericCloud-10-latest.x86_64.img centos-stream-10'"
```

```bash
ssh ubuntu@34.159.9.11 "ssh ubuntu@192.168.100.3 'source ~/admin_openrc && openstack image show centos-stream-10'"
```

## Chapter 8 - Configure an OpenStack Project

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack project create --domain admin_domain --enable --description \"Student Project\" StudentProject'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack user create --project StudentProject --email student@example.com --password openstack --enable student --domain admin_domain'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack role add --project-domain admin_domain --user-domain admin_domain --user student --project StudentProject Member'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cp os_files/student_* ~/"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack keypair create student-keypair > ~/.ssh/student-keypair.pem'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "ls -al ~/.ssh/student-keypair.pem"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "chmod 600 ~/.ssh/student-keypair.pem"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack keypair create --public-key ~/.ssh/id_rsa.pub existing-keypair'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack keypair list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group create --description \"Allow ICMP Traffic\" StudentProject_Allow_ICMP'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group rule create --proto icmp StudentProject_Allow_ICMP'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group rule create --proto icmp --egress StudentProject_Allow_ICMP'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group rule list StudentProject_Allow_ICMP'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group create --description \"Allow SSH Traffic\" StudentProject_Allow_SSH'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group rule create --proto tcp --dst-port 22 StudentProject_Allow_SSH'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group rule create --proto tcp --egress --dst-port 22 StudentProject_Allow_SSH'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack security group rule list StudentProject_Allow_SSH'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack quota show StudentProject'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack quota set --cores 40 --ram 25600 --instances 20 --volumes 5 --snapshots 5 --floating-ips 10 --secgroups 20 --secgroup-rules 200 StudentProject'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack quota show StudentProject'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack network create StudentProject_Network --mtu 1300'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack subnet create --ip-version 4 --allocation-pool start=10.20.30.10,end=10.20.30.199 --gateway=10.20.30.1 --dhcp --dns-nameserver 192.168.100.3 --dns-nameserver 8.8.8.8 --subnet-range 10.20.30.0/24 --network StudentProject_Network StudentProject_Subnet'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack network list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack subnet list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack network show StudentProject_Network'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack subnet show StudentProject_Subnet'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack router create StudentProject_Public_Router'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack router set --external-gateway Public_Network StudentProject_Public_Router'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack router add subnet StudentProject_Public_Router StudentProject_Subnet'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack router show StudentProject_Public_Router'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack floating ip create Public_Network'\''"'
```

## Chapter 9 - Work with Cloud Workload Instances

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack flavor create --vcpus 2 --ram 1024 --disk 5 --ephemeral 0 --swap 0 --public m1.smaller'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate create --zone nova kvm'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack host list --zone nova'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate add host kvm os-compute01.maas'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate add host kvm os-compute02.maas'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate add host kvm os-compute03.maas'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate add host kvm os-compute04.maas'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate show kvm'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate set --property kvm=true kvm'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack aggregate show kvm'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack flavor create --vcpus 1 --ram 512 --disk 5 --public kvm.smaller'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack flavor set --property aggregate_instance_extra_specs:kvm=true kvm.smaller'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack flavor show kvm.smaller'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "export JUJU_MODEL=uos && juju exec -u nova-cloud-controller/0 \"grep enabled_filters /etc/nova/nova.conf\""'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "export JUJU_MODEL=uos && juju config nova-cloud-controller scheduler-default-filters=ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter,DifferentHostFilter,SameHostFilter,AggregateInstanceExtraSpecsFilter"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "export JUJU_MODEL=uos && juju config nova-cloud-controller scheduler-default-filters"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "export JUJU_MODEL=uos && juju status nova-cloud-controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server create --availability-zone nova --image jammy --flavor m1.smaller --key-name student-keypair --security-group StudentProject_Allow_SSH --nic net-id=1d6562cd-9027-43ae-a12e-23f767a3eb8c jammy1'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack floating ip list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server add floating ip jammy1 192.168.100.180'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack floating ip list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "ping -c 4 192.168.100.180"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server show jammy1 -c security_groups -f value'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server add security group jammy1 StudentProject_Allow_ICMP'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server show jammy1 -c security_groups -f value'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "ping -c 4 192.168.100.180"'
```

## Chapter 10 - OpenStack Storage

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack volume create volume1 --availability-zone nova --size 5 --description '"'"'StudentProject Volume 01'"'"'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack volume list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack volume show volume1'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server add volume --device /dev/vdb jammy1 volume1'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server show jammy1 -c volumes_attached -f value'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server show jammy1 -c key_name -f value'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server show jammy1 -c addresses -f value'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "ssh -o StrictHostKeyChecking=no -i ~/.ssh/student-keypair.pem ubuntu@192.168.100.180 sudo fdisk -l 2>&1 | head -30"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && openstack server delete jammy1'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/student_openrc && sleep 5 && openstack volume delete volume1'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack container create mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack container list'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack container show mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "mkdir ~/mydata"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "echo \"my file 1\" > ~/mydata/myfile01.txt && echo \"my file 2\" > ~/mydata/myfile02.txt"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && cd ~/mydata && openstack object create mydata *'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack container show mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack object list mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && swift stat mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && swift post mydata --read-acl ".r:*"'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && swift stat mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack object list mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && cd ~ && openstack object save mydata myfile01.txt'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "ls -l ~/myfile01.txt"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack endpoint list --service object-store --interface public -f value'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''export JUJU_MODEL=uos && source ~/admin_openrc && openstack object list mydata'\''"'
```

```bash
ssh ubuntu@34.159.9.11 << 'ENDSSH'
ssh ubuntu@192.168.100.3 << 'ENDMAAS'
bash -lc 'export JUJU_MODEL=uos && source ~/admin_openrc && export OBJECT_STORE_URL=$(openstack endpoint list --service object-store --interface public -f value | awk "{print \$7}") && wget $OBJECT_STORE_URL/mydata/myfile02.txt --ca-certificate=/home/ubuntu/snap/openstackclients/common/root-ca.crt -O /tmp/myfile02_wget.txt'
ENDMAAS
ENDSSH
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat /tmp/myfile02_wget.txt"'
```

## Chapter 11 - Configure Juju to Use OpenStack as a Provider

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat ~/os_files/glance-simplestreams-sync.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "export JUJU_MODEL=uos && juju deploy --to=lxd:3 --base ubuntu@22.04 --config ~/os_files/glance-simplestreams-sync.yaml --channel 2024.1/stable glance-simplestreams-sync"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "export JUJU_MODEL=uos && juju integrate glance-simplestreams-sync keystone"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "export JUJU_MODEL=uos && juju integrate glance-simplestreams-sync vault"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && echo SOURCED_OK'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat > ~/os_files/my-openstack.yaml <<'"'"'EOF'"'"'
clouds:
  my-openstack:
    type: openstack
    auth-types: [userpass]
    endpoint: https://192.168.100.29:5000/v3
    regions:
      RegionOne:
        endpoint: https://192.168.100.29:5000/v3
EOF"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju add-cloud --client my-openstack ~/os_files/my-openstack.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat > ~/os_files/my-openstack-creds.yaml <<'"'"'EOF'"'"'
credentials:
  my-openstack:
    student:
      auth-type: userpass
      username: student
      password: openstack
      tenant-name: StudentProject
      user-domain-name: admin_domain
      project-domain-name: admin_domain
EOF"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju add-credential my-openstack --client -f ~/os_files/my-openstack-creds.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack endpoint list --service swift --interface public -f value'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat > ~/os_files/my-config.yaml <<'"'"'EOF'"'"'
network: StudentProject_Network
external-network: Public_Network
image-metadata-url: https://192.168.100.43:443/swift/v1/simplestreams/data/
default-base: ubuntu@22.04
ssl-hostname-verification: false
EOF"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/student_openrc && openstack floating ip create Public_Network'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack flavor create --vcpus 2 --ram 2048 --disk 10 --ephemeral 0 --swap 0 --public kvm.node'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "bash -lc '\''source ~/admin_openrc && openstack flavor set --property aggregate_instance_extra_specs:kvm=true kvm.node'\''"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju bootstrap --config ~/os_files/my-config.yaml --bootstrap-constraints=\"mem=2G cores=2 allocate-public-ip=true\" --constraints=\"mem=2G\" my-openstack my-controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju controllers"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "cat ~/os_files/landscape_bundle.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju add-model landscape --config ssl-hostname-verification=false"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju set-model-constraints -m landscape allocate-public-ip=true"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju deploy -m landscape ./os_files/landscape_bundle.yaml"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m landscape"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status haproxy -m landscape --format line | grep -v ^$ | awk '"'"'{print $3}'"'"' | head -1"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju switch maas-controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju destroy-controller --destroy-all-models my-controller --no-prompt"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m maas-controller:controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m maas-controller:uos"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju deploy -m maas-controller:controller juju-dashboard dashboard --to=lxd:0 --channel 0.15/stable"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju integrate -m maas-controller:controller dashboard controller"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju expose -m maas-controller:controller dashboard"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju status -m maas-controller:controller dashboard"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju dashboard -m maas-controller:controller --no-browser-login"'
```

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "juju ssh -m maas-controller:controller 0 -- free -h"'
```
