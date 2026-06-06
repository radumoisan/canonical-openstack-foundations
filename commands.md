# Successful Command Reference

These are exact successful commands preserved as execution references for this lab environment.

## Canonical SSH access

Use this command to reach the student host:

```bash
ssh ubuntu@34.159.9.11
```

Use this pattern to run commands on the MAAS VM from the student host:

```bash
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "<command>"'
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
ssh ubuntu@34.159.9.11 'ssh ubuntu@192.168.100.3 "curl -sk -o /dev/null -w \"%{http_code}\" https://192.168.100.35/horizon"'
```
