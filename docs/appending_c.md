# 12.3 Appendix C: Horizon-Only OpenStack Showcase

This appendix provides a compact end-to-end Horizon-based showcase of common OpenStack tasks. All cloud operations are performed in Horizon. Only the local image conversion step and the final SSH login are performed from the workstation terminal.

!!! note
    Use the browser proxy path from Chapter 1 and the Horizon access details from Chapter 5 to reach the dashboard at `https://192.168.100.35/horizon`.

**12.3.1 Prepare the CentOS Stream Image**

Before opening Horizon, convert the CentOS Stream cloud image in the project root from `qcow2` to `raw` format on the workstation where this repository is checked out.

```bash
# convert the CentOS Stream qcow2 image in the project root to raw format
qemu-img convert -f qcow2 -O raw /home/radu/Dev/cb-canonical-openstack-foundations/CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2 /home/radu/Dev/cb-canonical-openstack-foundations/CentOS-Stream-GenericCloud-10-latest.x86_64.img
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
> `Image File`: **/home/radu/Dev/cb-canonical-openstack-foundations/CentOS-Stream-GenericCloud-10-latest.x86_64.img**<br/>
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

**12.3.4 Log In as the New Project User**

**To switch from the admin account to the new project user perform the following:**

1. Log out of the Horizon dashboard.
2. Log back in with the following account:
> `Domain`: **admin_domain**<br/>
> `Username`: **demo**<br/>
> `Password`: **openstack**
3. Confirm that only the `Project` and `Identity` panels are available on the left.

**12.3.5 Create a Key Pair and Allow SSH**

**To create a key pair and allow SSH access via Horizon perform the following:**

1. From the panels on the left select `Project > Compute > Key Pairs`.
2. Click `Create Key Pair`.
3. On the `Create Key Pair` screen, enter the following:
> `Key Pair Name`: **demo_keypair**<br/>
> `Key Type`: **SSH Key**
4. Click `Create Key Pair` and download the private key when prompted.
5. Keep the downloaded private key on the workstation that you will use for the final SSH step.
6. From the panels on the left select `Project > Network > Security Groups`.
7. Next to the `default` security group, click `Manage Rules`.
8. Click `Add Rule`.
9. On the `Add Rule` screen, enter or select the following:
> `Rule`: **SSH**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
10. Click `Add`.

**12.3.6 Create a Local Network and Router**

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
> `Allocation Pools`: **10.40.50.10, 10.40.50.200**<br/>
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

**12.3.7 Create a Small CentOS Virtual Machine**

**To launch a small CentOS instance via Horizon perform the following:**

1. From the panels on the left select `Project > Compute > Instances`.
2. Click `Launch Instance`.
3. On the `Details` tab, enter or select the following:
> `Instance Name`: **demo_vm**<br/>
> `Availability Zone`: **nova**<br/>
> `Count`: **1**
4. Click `Next`.
5. On the `Source` tab, set `Select Boot Source` to **Image** and `Create New Volume` to **No**.
6. Move `centos-stream-10` from `Available` to `Allocated`.
7. Click `Next`.
8. On the `Flavor` tab, move `m1.smaller` from `Available` to `Allocated`.
9. Click `Next`.
10. On the `Networks` tab, move `demo_net` from `Available` to `Allocated`.
11. Click `Next` twice.
12. On the `Security Groups` tab, keep `default` assigned to the instance.
13. Click `Next`.
14. On the `Key Pair` tab, move `demo_keypair` from `Available` to `Allocated`.
15. Click `Launch Instance`.

!!! note
    The instance initially shows status `Build` and then transitions to `Active` when deployment finishes.

**12.3.8 Assign a Floating IP to the New Instance**

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

**12.3.9 Connect to the Instance over SSH**

After the floating IP is associated, connect from the workstation terminal. The default login user for the CentOS Stream Generic Cloud image is `cloud-user`.

```bash
# restrict permissions on the downloaded private key
chmod 600 ~/Downloads/demo_keypair.pem
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# connect to the CentOS instance using the downloaded private key
ssh -i ~/Downloads/demo_keypair.pem cloud-user@FLOATING_IP
```

??? example "Expected result"
    ```bash
    The authenticity of host 'FLOATING_IP (FLOATING_IP)' can't be established.
    ED25519 key fingerprint is SHA256:[redacted].
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added 'FLOATING_IP' (ED25519) to the list of known hosts.
    [cloud-user@demo_vm ~]$
    ```
