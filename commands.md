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
