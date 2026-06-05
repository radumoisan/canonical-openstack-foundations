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
