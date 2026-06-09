# 12.3 Appendix C: Horizon OpenStack Demo

This appendix provides a compact end-to-end Horizon-based showcase of common OpenStack tasks. All cloud operations are performed in Horizon. Only the local image conversion step and the final SSH login are performed from the workstation terminal.

!!! note
    Use the browser proxy path from Chapter 1 and the Horizon access details from Chapter 5 to reach the dashboard at `https://192.168.100.35/horizon`.

**Objectives**

- Convert and upload a CentOS Stream cloud image.
- Create a project, user, and role assignment.
- Adjust project quotas.
- Create a public flavor for the demo VM.
- Build a project network with a subnet and router.
- Launch an instance and assign a floating IP.
- Demonstrate failed connectivity before security group changes.
- Update the default security group for SSH and ICMP.
- Verify ping and SSH access to the instance.
- Create and attach a block storage volume.
- Verify the attached volume from inside the instance.

**12.3.1 Prepare the CentOS Stream Image**

Before opening Horizon, convert the CentOS Stream cloud image in the project root from `qcow2` to `raw` format on the workstation where this repository is checked out.

```bash
# convert the CentOS Stream qcow2 image in the project root to raw format
qemu-img convert -f qcow2 -O raw CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2 CentOS-Stream-GenericCloud-10-latest.x86_64.img
```

??? example "Expected result"
    ```bash
    No output.
    ```

**12.3.2 Upload the CentOS Stream Image in Horizon**

**To upload the image via Horizon perform the following:**

1. Log into the dashboard as the `admin` user.
2. From the list of panels on the left select `Admin > Compute > Images`.
3. Click `Create Image`.
4. On the `Create An Image` screen, enter or select the following values and leave all unspecified values at their defaults:
> `Image Name`: **centos-stream-10**<br/>
> `Description`: **CentOS Stream 10 Generic Cloud**<br/>
> `Source Type`: **File** and then `Browse`<br/>
> `Image File`: **CentOS-Stream-GenericCloud-10-latest.x86_64.img**<br/>
> `Format`: **RAW**<br/>
> `Architecture`: **x86_64**<br/>
> `Minimum Disk (GB)`: **leave blank**<br/>
> `Minimum RAM (MB)`: **leave blank**<br/>
> `Visibility`: **Public**<br/>
> `Protected`: **no**
5. Click `Create Image`.
6. Wait for `centos-stream-10` to reach `Active` status.
7. From `Admin > Compute > Images`, open the action menu for `centos-stream-10` and select `Update Metadata`.
8. On the `Update Image Metadata` page, locate `hw_disk_bus` under `Available Metadata`.
9. Click the `+` next to `hw_disk_bus` and enter `virtio` for the value in the `Existing Metadata` section.
10. Click `Save`.

**12.3.3 Create a New Project and User**

**To create a new project and a member user via Horizon perform the following:**

1. From the panels on the left select `Identity > Projects`.
2. Click `Create Project`.
3. On the `Create Project` screen, on the `Project Information` tab, enter the following:
> `Name`: **DemoProject**<br/>
> `Description`: **Demo project**<br/>
> `Enabled`: **(checked)**
4. Click `Create Project`.
5. From the panels on the left select `Identity > Users`.
6. Click `Create User`.
7. On the `Create User` screen, enter or select the following:
> `User Name`: **demo**<br/>
> `Email`: **demo@example.com**<br/>
> `Password`: **openstack**<br/>
> `Primary Project`: **DemoProject**<br/>
> `Role`: **Member**<br/>
> `Enabled`: **(checked)**
8. Click `Create User`.

**12.3.4 Adjust Quotas for DemoProject**

**To adjust the DemoProject quotas via Horizon perform the following:**

1. From the panels on the left select `Identity > Projects`.
2. Next to `DemoProject`, open the action menu and select `Modify Quotas`.
3. On the `Edit Project` screen, open the `Quota` tab and change the following values, leaving all other quota settings unchanged:
> `VCPUs`: **4**<br/>
> `RAM (MB)`: **8192**
4. Click `Save`.

**12.3.5 Create a Flavor for the Demo VM**

**To create a flavor via Horizon perform the following:**

1. From the panels on the left select `Admin > Compute > Flavors`.
2. Click `Create Flavor`.
3. On the `Create Flavor` screen, enter or select the following values and leave all unspecified values at their defaults:
> `Name`: **demo.small**<br/>
> `ID`: **auto**<br/>
> `VCPUs`: **2**<br/>
> `RAM MB`: **1024**<br/>
> `Root Disk GB`: **5**<br/>
> `Ephemeral Disk GB`: **0**<br/>
> `Swap Disk MB`: **0**<br/>
> `Visibility`: **Public**
4. Click `Create Flavor`.
5. Confirm that `demo.small` appears in the flavor list.

**12.3.6 Log In as the New Project User**

**To switch from the admin account to the new project user perform the following:**

1. Log out of the Horizon dashboard.
2. Log back in with the following account:
> `Domain`: **admin_domain**<br/>
> `Username`: **demo**<br/>
> `Password`: **openstack**
3. Confirm that only the `Project` and `Identity` panels are available on the left.
4. From the panels on the left select `Project > Compute > Overview` and confirm that the `Limit Summary` reflects the updated `VCPUs` and `RAM (MB)` quota values.

**12.3.7 Create a Key Pair for Instance Access**

**To create a key pair via Horizon perform the following:**

1. From the panels on the left select `Project > Compute > Key Pairs`.
2. Click `Create Key Pair`.
3. On the `Create Key Pair` screen, enter the following:
> `Key Pair Name`: **demo_keypair**<br/>
> `Key Type`: **SSH Key**
4. Click `Create Key Pair` and download the private key when prompted.
5. Keep the downloaded private key on the workstation that you will use later in the demo.

```bash
# copy the downloaded private key to the student host
scp ~/Downloads/demo_keypair.pem ubuntu@34.159.9.11:~/
```

??? example "Expected result"
    ```bash
    demo_keypair.pem                                                                                                 100% 1675     4.4KB/s   00:00
    ```

**12.3.8 Create a Local Network and Router**

**To create a project network and connect it to the external network via Horizon perform the following:**

1. From the panels on the left select `Project > Network > Networks`.
2. Click `Create Network`.
3. On the `Create Network` screen `Network` tab, enter or select the following:
> `Name`: **demo_net**<br/>
> `Enable Admin State`: **(checked)**<br/>
> `Create Subnet`: **(checked)**
4. Click `Next`.
5. On the `Subnet` tab, enter or select the following:
> `Subnet Name`: **demo_subnet**<br/>
> `Network Address`: **10.40.50.0/24**<br/>
> `IP Version`: **IPv4**<br/>
> `Gateway IP`: **10.40.50.1**<br/>
> `Disable Gateway`: **(unchecked)**
6. Click `Next`.
7. On the `Subnet Details` tab, enter or select the following:
> `Enable DHCP`: **(checked)**<br/>
> `Allocation Pools`: **10.40.50.10,10.40.50.200**<br/>
> `DNS Name Servers`: **192.168.100.3**<br/>
> `Host Routes`: **(leave blank)**
8. Click `Create Network`.
9. From the panels on the left select `Project > Network > Routers`.
10. Click `Create Router`.
11. On the `Create Router` screen, enter or select the following:
> `Router Name`: **demo_router**<br/>
> `Enable Admin State`: **(checked)**<br/>
> `External Network`: **Public_Network**
12. Click `Create Router`.
13. Click `demo_router` in the router list.
14. Open the `Interfaces` tab and click `Add Interface`.
15. On the `Add Interface` screen, enter or select the following:
> `Subnet`: **demo_net 10.40.50.0/24 (demo_subnet)**<br/>
> `IP Address (optional)`: **(leave blank)**
16. Click `Submit`.

**12.3.9 Create a Small CentOS Virtual Machine**

**To launch a small CentOS instance via Horizon perform the following:**

1. From the panels on the left select `Project > Compute > Instances`.
2. Click `Launch Instance`.
3. On the `Details` tab, enter or select the following:
> `Instance Name`: **demo_vm**<br/>
> `Availability Zone`: **nova**<br/>
> `Count`: **1**
4. Click `Next`.
5. On the `Source` tab, set or select the following:
> `Select Boot Source`: **Image**<br/>
> `Create New Volume`: **Yes**<br/>
> `Volume Size (GB)`: **10**<br/>
> `Delete Volume on Instance Delete`: **No**
6. Move `centos-stream-10` from `Available` to `Allocated`.
7. Click `Next`.
8. On the `Flavor` tab, move `demo.small` from `Available` to `Allocated`.
9. Click `Next`.
10. On the `Networks` tab, move `demo_net` from `Available` to `Allocated`.
11. Click `Next` twice.
12. On the `Security Groups` tab, keep `default` assigned to the instance.
13. Click `Next`.
14. On the `Key Pair` tab, move `demo_keypair` from `Available` to `Allocated`.
15. Click `Launch Instance`.

!!! note
    The instance initially shows status `Build` and then transitions to `Active` when deployment finishes.

**12.3.10 Assign a Floating IP to the New Instance**

**To allocate and associate a floating IP via Horizon perform the following:**

1. From the panels on the left select `Project > Network > Floating IPs`.
2. Click `Allocate IP To Project`.
3. On the `Allocate Floating IP` screen, select `Public_Network` from the `Pool` list.
4. Click `Allocate IP`.
5. From the panels on the left select `Project > Compute > Instances`.
6. Next to `demo_vm`, select `Associate Floating IP` from the action menu.
7. On the `Manage Floating IP Associations` screen, select the floating IP you just allocated and accept the default port.
8. Click `Associate`.
9. Confirm that the floating IP now appears in the `IP Address` column next to `demo_vm`.

**12.3.11 Demonstrate That Connectivity Fails by Default**

At this point the instance uses the `default` security group with no custom ingress rules. Ping and SSH should fail.

```bash
# connect to the student host
ssh ubuntu@34.159.9.11
```

??? example "Expected result"
    ```bash
    Welcome to Ubuntu 22.04 LTS (GNU/Linux 5.15.0-xx-generic x86_64)
    ubuntu@training-host:~$
    ```

```bash
# restrict permissions on the private key on the student host
chmod 600 ~/demo_keypair.pem
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm that ICMP is blocked before updating the security group
ping -c 4 FLOATING_IP
```

??? example "Expected result"
    ```bash
    PING FLOATING_IP (FLOATING_IP) 56(84) bytes of data.

    --- FLOATING_IP ping statistics ---
    4 packets transmitted, 0 received, 100% packet loss, time 3071ms
    ```

```bash
# confirm that SSH is blocked before updating the security group
ssh -o ConnectTimeout=10 -i ~/demo_keypair.pem cloud-user@FLOATING_IP
```

??? example "Expected result"
    ```bash
    ssh: connect to host FLOATING_IP port 22: Connection timed out
    ```

**12.3.12 Update the Default Security Group for SSH and ICMP**

**To allow SSH and ICMP traffic via Horizon perform the following:**

1. Return to the Horizon browser session and select `Project > Network > Security Groups`.
2. Next to the `default` security group, click `Manage Rules`.
3. Click `Add Rule`.
4. On the `Add Rule` screen, enter or select the following:
> `Rule`: **SSH**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
5. Click `Add`.
6. Click `Add Rule` again.
7. On the `Add Rule` screen, enter or select the following:
> `Rule`: **ALL ICMP**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
8. Click `Add`.

!!! note
    The default security group already includes the required egress rules in this environment. For this demo, only the ingress rules need to be added.

**12.3.13 Verify Ping and SSH Access**

Return to the student host terminal and retry the connectivity checks.

```bash
# confirm that ICMP now works after the security group update
ping -c 4 FLOATING_IP
```

??? example "Expected result"
    ```bash
    PING FLOATING_IP (FLOATING_IP) 56(84) bytes of data.
    64 bytes from FLOATING_IP: icmp_seq=1 ttl=64 time=0.550 ms
    64 bytes from FLOATING_IP: icmp_seq=2 ttl=64 time=0.601 ms
    64 bytes from FLOATING_IP: icmp_seq=3 ttl=64 time=0.579 ms
    64 bytes from FLOATING_IP: icmp_seq=4 ttl=64 time=0.588 ms

    --- FLOATING_IP ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3072ms
    ```

```bash
# connect to the CentOS instance from the student host
ssh -i ~/demo_keypair.pem cloud-user@FLOATING_IP
```

??? example "Expected result"
    ```bash
    The authenticity of host 'FLOATING_IP (FLOATING_IP)' can't be established.
    ED25519 key fingerprint is SHA256:[redacted].
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added 'FLOATING_IP' (ED25519) to the list of known hosts.
    [cloud-user@demo_vm ~]$
    ```

**12.3.14 Create and Attach a Volume via Horizon**

**12.3.14.1 Create a Storage Volume**

**To create a storage volume via Horizon perform the following:**

1. From the panels on the left select `Project > Volumes > Volumes`.
2. Click `Create Volume`.
3. On the `Create Volume` screen, enter or select the following:
> `Volume Name`: **demo_vol**<br/>
> `Description`: **DemoProject Volume 01**<br/>
> `Volume Source`: **No source, empty volume**<br/>
> `Type`: **No volume type**<br/>
> `Size (GB)`: **5**<br/>
> `Availability Zone`: **nova**
4. Click `Create Volume`.
5. Wait for `demo_vol` to reach the `Available` state.

**12.3.14.2 Attach the Volume to demo_vm**

**To attach the volume to the existing instance via Horizon perform the following:**

1. From the panels on the left select `Project > Volumes > Volumes`.
2. Next to `demo_vol`, open the action menu and select `Manage Attachments`.
3. On the `Manage Volume Attachments` screen, select `demo_vm` from the `Attach to Instance` list.
4. Click `Attach Volume`.
5. Confirm that `demo_vm` now appears in the `Attached To` column for `demo_vol`.
6. From the panels on the left select `Project > Compute > Instances`.
7. Click `demo_vm`.
8. On the `Instances / demo_vm` screen, confirm that `demo_vol` appears under `Volumes Attached`.

**12.3.15 Verify the Attached Volume over SSH**

From the student host terminal, verify that the additional volume is visible inside the CentOS instance.

```bash
# display block devices inside the CentOS instance
ssh -i ~/demo_keypair.pem cloud-user@FLOATING_IP lsblk
```

??? example "Expected result"
    ```bash
    NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
    vda    252:0    0  10G  0 disk
    |-vda1 252:1    0   1M  0 part
    |-vda2 252:2    0 200M  0 part /boot/efi
    `-vda3 252:3    0 9.8G  0 part /
    vdb    252:16   0   5G  0 disk
    ```
