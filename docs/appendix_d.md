# 12.4 Appendix D: Horizon Octavia Load Balancer Demo

This appendix provides a compact Horizon-based Octavia exercise that uses two Ubuntu workload instances running Apache behind a load balancer. All OpenStack resource changes are performed in Horizon. The Apache installation, `curl` tests, and service stop and start operations are performed from the student host terminal over SSH.

!!! note
    Use the Horizon access details provided for this validation environment to reach the dashboard.

!!! note
    This appendix assumes the cloud already has Octavia installed, the Horizon load balancer panels are enabled, and the project can create instances, floating IPs, and load balancers in this environment.

!!! note
    This appendix runs on a different student host and OpenStack environment from the earlier training chapters. Focus on the Octavia workflow and validation steps here; the environment-specific machine details are not part of the exercise.

!!! success "**Objectives**"
    - [x] Launch two Ubuntu backend instances from Horizon.
    - [x] Assign floating IP addresses and verify direct SSH and HTTP access.
    - [x] Install Apache on both backends and publish distinct landing pages.
    - [x] Create an Octavia load balancer with an HTTP listener and a round-robin pool.
    - [x] Demonstrate successful round-robin responses through the VIP.
    - [x] Show that a `PING` health monitor only proves that the VM is reachable.
    - [x] Replace the `PING` monitor with an `HTTP` monitor that checks `/healthcheck`.
    - [x] Verify that the HTTP monitor removes a failed backend from service.

**12.4.1 Review the Starting Conditions**

Before starting the appendix, expect the following to already be available in this validation environment:

1. Horizon is reachable and the left navigation shows `Project > Network > Load Balancers`.
2. At least one Ubuntu image is available for launching the backend instances.
3. An SSH key pair is already available for this environment.
4. A private project network and subnet are available for the backend instances.
5. The project can allocate at least three floating IP addresses from the external network used in this environment.

If any of these prerequisites are missing, stop and correct them in Horizon before continuing.

!!! note
    The exact load balancer dialog labels can vary slightly between Horizon releases. Use the closest matching field names if your dashboard wording differs.

**12.4.2 Allow SSH, ICMP, and HTTP in the Default Security Group**

**To prepare the default project security group via Horizon perform the following:**

1. From the panels on the left select `Project > Network > Security Groups`.
2. Next to the `default` security group, click `Manage Rules`.
3. Confirm that the following ingress rules exist. If any rule is missing, add it.
4. For SSH access, click `Add Rule` and enter or select the following:
> `Rule`: **SSH**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
5. Click `Add`.
6. For ICMP reachability, click `Add Rule` again and enter or select the following:
> `Rule`: **ALL ICMP**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
7. Click `Add`.
8. For HTTP access, click `Add Rule` again and enter or select the following:
> `Rule`: **HTTP**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
9. Click `Add`.

!!! warning
    Some Horizon releases have a known bug where the `SSH` and `HTTP` preset rules silently fail to appear after you click `Add`. If that happens, use `Custom TCP Rule` instead and create one ingress rule for port `22` and one ingress rule for port `80`, both with `Remote = CIDR` and `CIDR = 0.0.0.0/0`.

!!! note
    In this lab environment, the default security group already includes the required egress rules. For this appendix, only the ingress rules above need to be present.

**12.4.3 Launch the First Ubuntu Backend Instance**

**To launch the first backend instance via Horizon perform the following:**

1. From the panels on the left select `Project > Compute > Instances`.
2. Click `Launch Instance`.
3. On the `Details` tab, enter or select the following:
> `Instance Name`: **web-1**<br/>
> `Availability Zone`: **nova**<br/>
> `Count`: **1**
4. On the `Source` tab, enter or select the following:
> `Select Boot Source`: **Image**<br/>
> `Create New Volume`: **Yes**<br/>
> `Volume Size (GB)`: **5**<br/>
> `Allocated`: **ubuntu-24.04**
5. On the `Flavor` tab, move `c1.small` from `Available` to `Allocated`.
6. On the `Networks` tab, move `local-net` from `Available` to `Allocated`.
7. On the `Security Groups` tab, keep `default` assigned to the instance.
8. On the `Key Pair` tab, move `bootstrap` from `Available` to `Allocated`.
9. Click `Launch Instance`.
10. Wait for `web-1` to reach the `Active` state.

**12.4.4 Launch the Second Ubuntu Backend Instance**

**To launch the second backend instance via Horizon perform the following:**

1. From `Project > Compute > Instances`, click `Launch Instance` again.
2. Repeat the same tab selections as in the previous task with the following change:
> `Instance Name`: **web-2**
3. Click `Launch Instance`.
4. Wait for `web-2` to reach the `Active` state.
5. In the `IP Address` column for both instances, record the fixed IP addresses shown on `local-net`. You will use them later when adding pool members.

**12.4.5 Create the Project Router and Assign Floating IP Addresses to Both Backend Instances**

**To prepare external access for the backend instances via Horizon perform the following:**

1. From `Project > Network > Routers`, click `Create Router`.
2. On the `Create Router` screen, enter or select the following:
> `Name`: **local-router**<br/>
> `External Network`: **office**
3. Click `Create Router`.

!!! note
    Open `Project > Network > Network Topology` after creating the router. This makes it easier to see the new `local-router` object and its relationship to the external network.

4. Open `local-router`, select the `Interfaces` tab, and click `Add Interface`.
5. On the `Add Interface` screen, select the following:
> `Subnet`: **local-subnet**
6. Click `Add Interface`.

!!! note
    Return to `Project > Network > Network Topology` after adding the interface. This view makes it easier to confirm that `local-net` is now connected to `local-router`.

7. From `Project > Network > Floating IPs`, click `Allocate IP To Project`.
8. On the `Allocate Floating IP` screen, select `office` from the `Pool` list.
9. Click `Allocate IP`.
10. Repeat the allocation once more so that you have two free floating IP addresses.
11. From `Project > Compute > Instances`, next to `web-1`, select `Associate Floating IP` from the action menu.
12. On the `Manage Floating IP Associations` screen, select one of the newly allocated floating IP addresses and accept the default port, then click `Associate`.
13. Repeat the same association process for `web-2` using the second floating IP address.
14. Record the two external addresses for later use from the shell on the student host.

!!! note
    Check `Project > Network > Network Topology` again after the floating IP associations. This helps you see the router, the private network, and the external reachability in one place before you move on.

!!! note
    The backend instances need floating IP addresses for direct SSH access and direct HTTP checks later in the appendix. Octavia still uses the instances' fixed IP addresses on `local-net` when you add them as pool members.

!!! warning
    If Horizon reports that the subnet is already using gateway IP `10.0.20.1` when you add the router interface, the subnet is already attached to another router. In that case, keep the existing routing path and continue with the floating IP allocation and association steps instead of adding a second router interface.

**12.4.6 Connect to the Student Host**

From the workstation terminal, connect to the student host for this validation environment. That host should already contain the OpenStack credentials and the SSH private key you will use for the backend instances.

!!! note
    Replace the example host address, key path, and IP addresses in the next commands with the actual values for this environment before you continue.

```bash
# connect to the student host
ssh ubuntu@<student-host-address>
```

??? example "Expected result"
    ```bash
    Welcome to Ubuntu 22.04 LTS (GNU/Linux 5.15.0-xx-generic x86_64)
    ubuntu@training-host:~$
    ```

```bash
# set the path to the SSH private key for the backend instances
export SSH_KEY_PATH=~/.ssh/my-private-key.pem
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm the student private key uses restrictive permissions
chmod 600 "$SSH_KEY_PATH"
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# export the recorded backend and VIP addresses for reuse in the remaining commands
export WEB1_FIXED_IP=10.20.30.161 WEB2_FIXED_IP=10.20.30.162 WEB1_FLOATING_IP=192.168.100.180 WEB2_FLOATING_IP=192.168.100.181 VIP_FLOATING_IP=192.168.100.182
```

??? example "Expected result"
    ```bash
    No output.
    ```

**12.4.7 Install Apache on web-1**

```bash
# connect to the first backend instance
ssh -i "$SSH_KEY_PATH" ubuntu@$WEB1_FLOATING_IP
```

??? example "Expected result"
    ```bash
    The authenticity of host '192.168.100.180 (192.168.100.180)' can't be established.
    ED25519 key fingerprint is SHA256:[redacted].
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '192.168.100.180' (ED25519) to the list of known hosts.
    ubuntu@web-1:~$
    ```

```bash
# refresh the package index on web-1
sudo apt update
```

??? example "Expected result"
    ```bash
    Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
    Hit:2 http://archive.ubuntu.com/ubuntu jammy-updates InRelease
    Hit:3 http://archive.ubuntu.com/ubuntu jammy-security InRelease
    Reading package lists... Done
    Building dependency tree... Done
    All packages are up to date.
    ```

```bash
# install the Apache web server on web-1
sudo apt install -y apache2
```

??? example "Expected result"
    ```bash
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    The following NEW packages will be installed:
      apache2 apache2-bin apache2-data apache2-utils
    ...
    Setting up apache2 ...
    Created symlink /etc/systemd/system/multi-user.target.wants/apache2.service -> /lib/systemd/system/apache2.service.
    ```

```bash
# verify that Apache is running on web-1
sudo systemctl is-active apache2
```

??? example "Expected result"
    ```bash
    active
    ```

```bash
# publish a unique landing page on web-1
printf '%s\n' '<h1>Apache backend web-1</h1>' | sudo tee /var/www/html/index.html
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-1</h1>
    ```

```bash
# create a dedicated HTTP health check file on web-1
printf 'OK\n' | sudo tee /var/www/html/healthcheck
```

??? example "Expected result"
    ```bash
    OK
    ```

```bash
# verify the Apache landing page locally on web-1
curl -s http://127.0.0.1/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-1</h1>
    ```

```bash
# verify the HTTP health check file locally on web-1
curl -s http://127.0.0.1/healthcheck
```

??? example "Expected result"
    ```bash
    OK
    ```

```bash
# leave the web-1 SSH session
exit
```

??? example "Expected result"
    ```bash
    Connection to 192.168.100.180 closed.
    ```

**12.4.8 Install Apache on web-2**

```bash
# connect to the second backend instance
ssh -i "$SSH_KEY_PATH" ubuntu@$WEB2_FLOATING_IP
```

??? example "Expected result"
    ```bash
    The authenticity of host '192.168.100.181 (192.168.100.181)' can't be established.
    ED25519 key fingerprint is SHA256:[redacted].
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '192.168.100.181' (ED25519) to the list of known hosts.
    ubuntu@web-2:~$
    ```

```bash
# refresh the package index on web-2
sudo apt update
```

??? example "Expected result"
    ```bash
    Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
    Hit:2 http://archive.ubuntu.com/ubuntu jammy-updates InRelease
    Hit:3 http://archive.ubuntu.com/ubuntu jammy-security InRelease
    Reading package lists... Done
    Building dependency tree... Done
    All packages are up to date.
    ```

```bash
# install the Apache web server on web-2
sudo apt install -y apache2
```

??? example "Expected result"
    ```bash
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    The following NEW packages will be installed:
      apache2 apache2-bin apache2-data apache2-utils
    ...
    Setting up apache2 ...
    Created symlink /etc/systemd/system/multi-user.target.wants/apache2.service -> /lib/systemd/system/apache2.service.
    ```

```bash
# verify that Apache is running on web-2
sudo systemctl is-active apache2
```

??? example "Expected result"
    ```bash
    active
    ```

```bash
# publish a unique landing page on web-2
printf '%s\n' '<h1>Apache backend web-2</h1>' | sudo tee /var/www/html/index.html
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-2</h1>
    ```

```bash
# create a dedicated HTTP health check file on web-2
printf 'OK\n' | sudo tee /var/www/html/healthcheck
```

??? example "Expected result"
    ```bash
    OK
    ```

```bash
# verify the Apache landing page locally on web-2
curl -s http://127.0.0.1/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-2</h1>
    ```

```bash
# verify the HTTP health check file locally on web-2
curl -s http://127.0.0.1/healthcheck
```

??? example "Expected result"
    ```bash
    OK
    ```

```bash
# leave the web-2 SSH session
exit
```

??? example "Expected result"
    ```bash
    Connection to 192.168.100.181 closed.
    ```

**12.4.9 Verify Direct Backend Reachability and HTTP Responses**

```bash
# confirm that the first backend VM is reachable over ICMP
ping -c 4 $WEB1_FLOATING_IP
```

??? example "Expected result"
    ```bash
    PING 192.168.100.180 (192.168.100.180) 56(84) bytes of data.
    64 bytes from 192.168.100.180: icmp_seq=1 ttl=64 time=0.561 ms
    64 bytes from 192.168.100.180: icmp_seq=2 ttl=64 time=0.593 ms
    64 bytes from 192.168.100.180: icmp_seq=3 ttl=64 time=0.579 ms
    64 bytes from 192.168.100.180: icmp_seq=4 ttl=64 time=0.588 ms

    --- 192.168.100.180 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3070ms
    ```

```bash
# confirm that the second backend VM is reachable over ICMP
ping -c 4 $WEB2_FLOATING_IP
```

??? example "Expected result"
    ```bash
    PING 192.168.100.181 (192.168.100.181) 56(84) bytes of data.
    64 bytes from 192.168.100.181: icmp_seq=1 ttl=64 time=0.547 ms
    64 bytes from 192.168.100.181: icmp_seq=2 ttl=64 time=0.612 ms
    64 bytes from 192.168.100.181: icmp_seq=3 ttl=64 time=0.566 ms
    64 bytes from 192.168.100.181: icmp_seq=4 ttl=64 time=0.574 ms

    --- 192.168.100.181 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3068ms
    ```

```bash
# confirm that the first backend Apache page responds directly
curl -s http://$WEB1_FLOATING_IP/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-1</h1>
    ```

```bash
# confirm that the second backend Apache page responds directly
curl -s http://$WEB2_FLOATING_IP/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-2</h1>
    ```

**12.4.10 Create the Load Balancer, Listener, and Pool in Horizon**

**To create the load balancer via Horizon perform the following:**

1. From the panels on the left select `Project > Network > Load Balancers`.
2. Click `Create Load Balancer`.
3. On the `Create Load Balancer` screen, enter or select the following:
> `Name`: **demo-lb**<br/>
> `Description`: **Round-robin Apache demo**<br/>
> `VIP Subnet`: **the project subnet used by the backend instances**
4. Click `Create Load Balancer`.
5. Wait for `demo-lb` to reach the active or online state.
6. Open the action menu for `demo-lb` and select `Create Listener`.
7. On the `Create Listener` screen, enter or select the following:
> `Name`: **demo-listener-http**<br/>
> `Protocol`: **HTTP**<br/>
> `Protocol Port`: **80**
8. Click `Create Listener`.
9. Open the action menu for `demo-listener-http` and select `Create Pool`.
10. On the `Create Pool` screen, enter or select the following:
> `Name`: **demo-pool**<br/>
> `Protocol`: **HTTP**<br/>
> `Load Balancing Algorithm`: **ROUND_ROBIN**
11. Click `Create Pool`.
12. Wait until the load balancer, listener, and pool all return to an active or online state.

!!! note
    Use the same project subnet for the VIP and the backend members. The pool members must use the instances' fixed IP addresses on the project network, not their floating IP addresses.

**12.4.11 Add the Two Apache Backends as Pool Members**

**To add the backend members via Horizon perform the following:**

1. From `Project > Network > Load Balancers`, click `demo-lb`.
2. Open the `Pools` tab and click `demo-pool`.
3. Select `Add Members`.
4. Add the first backend member with the following values:
> `Subnet`: **the project subnet used by the backend instances**<br/>
> `IP Address`: **the fixed IP recorded for web-1**<br/>
> `Protocol Port`: **80**<br/>
> `Weight`: **1**
5. Click `Add`.
6. Repeat the process for the second backend member with the following values:
> `Subnet`: **the project subnet used by the backend instances**<br/>
> `IP Address`: **the fixed IP recorded for web-2**<br/>
> `Protocol Port`: **80**<br/>
> `Weight`: **1**
7. Wait until both members appear in the pool member list.

**12.4.12 Associate a Floating IP Address with the Load Balancer VIP**

**To expose the load balancer VIP externally via Horizon perform the following:**

1. From `Project > Network > Load Balancers`, click `demo-lb`.
2. Record the VIP address and the VIP port ID shown on the load balancer details page.
3. From the panels on the left select `Project > Network > Floating IPs`.
4. Click `Allocate IP To Project`.
5. On the `Allocate Floating IP` screen, select the external network used for floating IP allocation in this environment.
6. Click `Allocate IP`.
7. Next to the newly allocated address, click `Associate`.
8. In the port selection list, choose the load balancer VIP port that matches the `demo-lb` VIP port ID.
9. Click `Associate`.
10. Record the associated external address for later use from the shell on the student host.

!!! note
    Some Horizon releases display the load balancer name directly in the port list, while others only show the port ID. Match the VIP port carefully before confirming the association.

**12.4.13 Verify Round-Robin Responses Through the VIP**

```bash
# send repeated HTTP requests through the load balancer VIP
for i in {1..6}; do curl -s http://$VIP_FLOATING_IP/; printf '\n'; done
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-1</h1>
    <h1>Apache backend web-2</h1>
    <h1>Apache backend web-1</h1>
    <h1>Apache backend web-2</h1>
    <h1>Apache backend web-1</h1>
    <h1>Apache backend web-2</h1>
    ```

!!! note
    The exact request order can vary, but over several requests you should see responses from both backends while both Apache services are healthy.

**12.4.14 Create a PING Health Monitor**

**To create a basic VM reachability monitor via Horizon perform the following:**

1. From `Project > Network > Load Balancers`, click `demo-lb`.
2. Open the `Pools` tab and click `demo-pool`.
3. Click `Create Health Monitor`.
4. On the `Create Health Monitor` screen, enter or select the following:
> `Name`: **demo-hm-ping**<br/>
> `Type`: **PING**<br/>
> `Delay`: **5**<br/>
> `Timeout`: **3**<br/>
> `Max Retries`: **3**
5. Click `Create`.
6. Wait until the health monitor is active and both pool members show a healthy or online state.

**12.4.15 Stop Apache on web-1 and Observe the Limitation of PING Monitoring**

```bash
# stop Apache on the first backend while leaving the VM running
ssh -i "$SSH_KEY_PATH" ubuntu@$WEB1_FLOATING_IP sudo systemctl stop apache2
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm that the first backend VM is still alive at the network layer
ping -c 4 $WEB1_FLOATING_IP
```

??? example "Expected result"
    ```bash
    PING 192.168.100.180 (192.168.100.180) 56(84) bytes of data.
    64 bytes from 192.168.100.180: icmp_seq=1 ttl=64 time=0.565 ms
    64 bytes from 192.168.100.180: icmp_seq=2 ttl=64 time=0.590 ms
    64 bytes from 192.168.100.180: icmp_seq=3 ttl=64 time=0.577 ms
    64 bytes from 192.168.100.180: icmp_seq=4 ttl=64 time=0.584 ms

    --- 192.168.100.180 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3071ms
    ```

```bash
# confirm that the Apache service on the first backend no longer answers HTTP requests
curl -sS --max-time 5 http://$WEB1_FLOATING_IP/
```

??? example "Expected result"
    ```bash
    curl: (7) Failed to connect to 192.168.100.180 port 80 after 0 ms: Connection refused
    ```

!!! note
    Return to `Project > Network > Load Balancers` and inspect the `demo-pool` member list. With a `PING` monitor, `web-1` can still appear healthy because the VM is reachable even though the Apache application has stopped.

```bash
# send repeated HTTP requests through the VIP while one backend application is down
for i in {1..6}; do curl -s --max-time 5 http://$VIP_FLOATING_IP/ || printf 'request failed'; printf '\n'; done
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-2</h1>
    request failed
    <h1>Apache backend web-2</h1>
    request failed
    <h1>Apache backend web-2</h1>
    request failed
    ```

**12.4.16 Start Apache Again Before Replacing the Health Monitor**

```bash
# start Apache on the first backend again
ssh -i "$SSH_KEY_PATH" ubuntu@$WEB1_FLOATING_IP sudo systemctl start apache2
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm that the first backend Apache page responds again
curl -s http://$WEB1_FLOATING_IP/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-1</h1>
    ```

**12.4.17 Replace the PING Monitor with an HTTP Monitor**

**To replace the basic liveness monitor with an application-aware HTTP monitor via Horizon perform the following:**

1. From `Project > Network > Load Balancers`, click `demo-lb`.
2. Open the `Pools` tab and click `demo-pool`.
3. Delete the existing `demo-hm-ping` health monitor.
4. Confirm that the pool returns to an active state.
5. Click `Create Health Monitor`.
6. On the `Create Health Monitor` screen, enter or select the following:
> `Name`: **demo-hm-http**<br/>
> `Type`: **HTTP**<br/>
> `URL Path`: **/healthcheck**<br/>
> `Expected Codes`: **200**<br/>
> `Delay`: **5**<br/>
> `Timeout`: **3**<br/>
> `Max Retries`: **3**
7. Click `Create`.
8. Wait until the new HTTP health monitor is active and both members return to a healthy or online state.

**12.4.18 Stop Apache on web-1 Again and Verify That HTTP Monitoring Protects the Service**

```bash
# stop Apache on the first backend again to trigger the HTTP monitor
ssh -i "$SSH_KEY_PATH" ubuntu@$WEB1_FLOATING_IP sudo systemctl stop apache2
```

??? example "Expected result"
    ```bash
    No output.
    ```

!!! note
    Return to `Project > Network > Load Balancers` and inspect the `demo-pool` members. After a short delay, the member for `web-1` should leave the healthy or online state because `/healthcheck` no longer returns `200`.

```bash
# wait for the HTTP health monitor to mark web-1 unhealthy
sleep 20
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm that requests through the VIP continue to succeed from the remaining healthy backend
for i in {1..6}; do curl -s --max-time 5 http://$VIP_FLOATING_IP/; printf '\n'; done
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-2</h1>
    <h1>Apache backend web-2</h1>
    <h1>Apache backend web-2</h1>
    <h1>Apache backend web-2</h1>
    <h1>Apache backend web-2</h1>
    <h1>Apache backend web-2</h1>
    ```

**12.4.19 Restore the Failed Backend After the Demo**

```bash
# start Apache on the first backend so both members can return to service
ssh -i "$SSH_KEY_PATH" ubuntu@$WEB1_FLOATING_IP sudo systemctl start apache2
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm that the first backend health endpoint responds again
curl -s http://$WEB1_FLOATING_IP/healthcheck
```

??? example "Expected result"
    ```bash
    OK
    ```

!!! note
    After the demo, give the HTTP monitor enough time to probe `web-1` again. The member should return to a healthy or online state in Horizon and the VIP should resume serving both backends over time.

**12.4.20 Optional Cleanup**

**To remove the demo resources after the exercise via Horizon perform the following:**

1. From `Project > Network > Load Balancers`, delete `demo-lb` and confirm the cascade delete of its child resources if Horizon prompts for it.
2. From `Project > Compute > Instances`, delete `web-1` and `web-2`.
3. From `Project > Network > Floating IPs`, release the three floating IP addresses used by `web-1`, `web-2`, and the VIP.
4. Wait until the instances, floating IP associations, and load balancer resources are removed.
