# 12.4 Appendix D: Horizon Octavia Load Balancer Demo

This appendix provides a compact Horizon-based Octavia exercise that uses two Ubuntu workload instances running Apache behind a load balancer. All OpenStack resource changes are performed in Horizon. The Apache installation, `curl` tests, and service stop and start operations are performed from a terminal over SSH.

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

1. From the panels on the left select `Project > Network > Security Groups`.
2. Next to the `default` security group, click `Manage Rules`.
3. Confirm that the following ingress rules exist. If any rule is missing, add it.
4. For SSH access, click `Add Rule`, enter or select the following, then click `Add`:
> `Rule`: **SSH**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
5. For ICMP reachability, click `Add Rule` again, enter or select the following, then click `Add`:
> `Rule`: **ALL ICMP**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**
6. For HTTP access, click `Add Rule` again, enter or select the following, then click `Add`:
> `Rule`: **HTTP**<br/>
> `Direction`: **Ingress**<br/>
> `Remote`: **CIDR**<br/>
> `CIDR`: **0.0.0.0/0**

!!! warning
    Some Horizon releases have a known bug where the `SSH` and `HTTP` preset rules silently fail to appear after you click `Add`. If that happens, use `Custom TCP Rule` instead and create one ingress rule for port `22` and one ingress rule for port `80`, both with `Remote = CIDR` and `CIDR = 0.0.0.0/0`.

**12.4.3 Launch the First Ubuntu Backend Instance**

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
8. On the `Key Pair` tab, move `bootstrap` from `Available` to `Allocated`, then click `Launch Instance`.
9. Wait for `web-1` to reach the `Active` state.

**12.4.4 Launch the Second Ubuntu Backend Instance**

1. From `Project > Compute > Instances`, click `Launch Instance` again.
2. Repeat the same tab selections as in the previous task with the following change, then click `Launch Instance`:
> `Instance Name`: **web-2**
3. Wait for `web-2` to reach the `Active` state.
4. In the `IP Address` column for both instances, record the fixed IP addresses shown on `local-net`. You will use them later when adding pool members.

**12.4.5 Floating IPs**

!!! note
    These floating IP addresses are only needed for the initial VM configuration and direct backend checks later in the appendix. Release them after section `12.4.7`. Octavia uses the instances' fixed IP addresses on `local-net`, not their floating IP addresses.

1. From `Project > Network > Routers`, click `Create Router`.
2. On the `Create Router` screen, enter or select the following, then click `Create Router`:
> `Name`: **local-router**<br/>
> `External Network`: **office**

!!! note ""
    Open `Project > Network > Network Topology` after creating the router. This makes it easier to see the new `local-router` object and its relationship to the external network.

3. Open `local-router`, select the `Interfaces` tab, and click `Add Interface`.
4. On the `Add Interface` screen, select the following, then click `Add Interface`:
> `Subnet`: **local-subnet**

!!! note ""
    Return to `Project > Network > Network Topology` after adding the interface. This view makes it easier to confirm that `local-net` is now connected to `local-router`.

5. From `Project > Network > Floating IPs`, click `Allocate IP To Project`.
6. On the `Allocate Floating IP` screen, select `office` from the `Pool` list, then click `Allocate IP`.
7. Repeat the allocation once more so that you have two free floating IP addresses.
8. From `Project > Compute > Instances`, next to `web-1`, select `Associate Floating IP` from the action menu.
9. On the `Manage Floating IP Associations` screen, select one of the newly allocated floating IP addresses and accept the default port, then click `Associate`.
10. Repeat the same association process for `web-2` using the second floating IP address.
11. Record the two external addresses for later use from the terminal.

!!! note ""
    Check `Project > Network > Network Topology` again after the floating IP associations. This helps you see the router, the private network, and the external reachability in one place before you move on.

**12.4.6 Connect to Each Backend and Install Apache**

```bash
# confirm the backend private key uses restrictive permissions
chmod 600 bootstrap.pem
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# connect to the first backend instance
ssh -i bootstrap.pem ubuntu@<web-1-floating-ip>
```

??? example "Expected result"
    ```bash
    The authenticity of host '192.168.100.88 (192.168.100.88)' can't be established.
    ED25519 key fingerprint is SHA256:[redacted].
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '192.168.100.88' (ED25519) to the list of known hosts.
    ubuntu@web-1:~$
    ```

```bash
# set a password for the ubuntu user so you can use the Horizon web console later
sudo passwd ubuntu
```

??? example "Expected result"
    ```bash
    New password:
    Retype new password:
    passwd: password updated successfully
    ```

```bash
# install Apache, publish a unique landing page, add a health check file, and verify both endpoints on web-1
sudo apt update && \
sudo apt install -y apache2 && \
printf '%s\n' '<h1>Apache backend web-1</h1>' | sudo tee /var/www/html/index.html && \
printf 'OK\n' | sudo tee /var/www/html/healthcheck && \
curl -s http://127.0.0.1/ && \
curl -s http://127.0.0.1/healthcheck
```

??? example "Expected result"
    ```bash
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    ...
    Setting up apache2 ...
    <h1>Apache backend web-1</h1>
    OK
    ```

```bash
# leave the web-1 SSH session
exit
```

??? example "Expected result"
    ```bash
    Connection to 192.168.100.88 closed.
    ```

> Repeat the same SSH, password update, Apache installation, landing page, and health check steps for `web-2`, using its floating IP address, setting the password to `openstack`, and **changing the landing page content to `<h1>Apache backend web-2</h1>`**.

**12.4.7 Verify Direct Backend Reachability and HTTP Responses**

```bash
# confirm that the first backend VM is reachable over ICMP
ping -c 4 <web-1-floating-ip>
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
ping -c 4 <web-2-floating-ip>
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
curl -s http://<web-1-floating-ip>/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-1</h1>
    ```

```bash
# confirm that the second backend Apache page responds directly
curl -s http://<web-2-floating-ip>/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-2</h1>
    ```

!!! note ""
    You can also perform the `curl` checks in a web browser by opening each backend floating IP address directly.

**12.4.8 Release the Backend Floating IPs**

1. From `Project > Compute > Instances`, next to `web-1`, select `Disassociate Floating IP`.
2. Repeat the same action for `web-2`.
3. From `Project > Network > Floating IPs`, release the two unassociated backend floating IP addresses.

!!! note
    The remaining service-management steps use a mix of Horizon instance actions and the Horizon web console with the `ubuntu` user and the password `openstack`.

**12.4.9 Create the Load Balancer in Horizon**

1. From the panels on the left select `Project > Network > Load Balancers`.
2. Click `Create Load Balancer`.
3. On the `Load Balancer Details` screen, enter or select the following, then click `Next`:
> `Name`: **demo-lb**<br/>
> `Description`: **Round-robin Apache demo**<br/>
> `Subnet`: **local-net: 10.0.20.0/24 (local-subnet)**<br/>
> `Admin State Up`: **Yes**
4. On the `Listener Details` screen, enter or select the following, then click `Next`:
> `Create Listener`: **Yes**<br/>
> `Name`: **demo-listener-http**<br/>
> `Protocol`: **HTTP**<br/>
> `Port`: **80**<br/>
> `Admin State Up`: **Yes**
5. On the `Pool Details` screen, enter or select the following, then click `Next`:
> `Create Pool`: **Yes**<br/>
> `Name`: **demo-pool**<br/>
> `Algorithm`: **ROUND_ROBIN**<br/>
> `Session Persistence`: **None**<br/>
> `TLS Enabled`: **No**<br/>
> `Admin State Up`: **Yes**
6. On the `Pool Members` screen, add `web-1` and `web-2`, then click `Next`.

7. On the `Monitor Details` screen, set `Create Health Monitor` to `No`, then click `Create Load Balancer`.
8. Wait until `demo-lb`, `demo-listener-http`, and `demo-pool` return to an active or online state and both backend members appear under the pool.

!!! note
    The load balancer wizard adds the backend members from the available instances list, but Octavia still uses the instances' fixed IP addresses on `local-net`, not their floating IP addresses.

**12.4.10 Associate a Floating IP Address with the Load Balancer VIP**

1. From `Project > Network > Load Balancers`, click `demo-lb`.
2. Record the VIP address and the VIP port ID shown on the load balancer details page.
3. From the panels on the left select `Project > Network > Floating IPs`.
4. Click `Allocate IP To Project`.
5. On the `Allocate Floating IP` screen, select the external network used for floating IP allocation in this environment.
6. Click `Allocate IP`.
7. Next to the newly allocated address, click `Associate`.
8. In the port selection list, choose the load balancer VIP port that matches the `demo-lb` VIP port ID.
9. Click `Associate`.
10. Record the associated external address for later use from the terminal.

!!! note
    Some Horizon releases display the load balancer name directly in the port list, while others only show the port ID. Match the VIP port carefully before confirming the association.

**12.4.11 Verify Round-Robin Responses Through the VIP**

```bash
# send repeated HTTP requests through the load balancer VIP
for i in {1..6}; do curl -s http://<vip-floating-ip>/; printf '\n'; done
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
    This test can be performed also from a Web browser by reloading the page multiple times.

1. From `Project > Compute > Instances`, use the instance action menu for `web-1` and shut the instance down.
2. Wait until `web-1` shows the `Shut Off` state in Horizon.

```bash
# send repeated HTTP requests through the VIP while one backend VM is powered off
for i in {1..6}; do curl -s --max-time 5 http://<vip-floating-ip>/ || printf 'request failed'; printf '\n'; done
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

!!! note
    Without a health monitor, `web-1` remains attached to the pool in Horizon even though the VM is shut down. In this environment, client requests continue to return content from `web-2` instead of marking `web-1` unhealthy.

!!! note "Observed behavior"
    Without a health monitor, the setup can still appear to work from the client side because the load balancer eventually serves content from `web-2`. However, this is still not ideal: incoming requests can still be sent to `web-1` first, fail internally, and only then be served by `web-2`. The backend is not proactively marked unhealthy.

3. From `Project > Compute > Instances`, use the instance action menu for `web-1` and start the instance again.
4. Wait until `web-1` returns to the `Active` state in Horizon.

```bash
# confirm that round-robin responses return after web-1 starts again
for i in {1..6}; do curl -s http://<vip-floating-ip>/; printf '\n'; done
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

**12.4.12 Create a PING Health Monitor**

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

**12.4.13 Stop Apache on web-1 and Observe the Limitation of PING Monitoring**

From `Project > Compute > Instances`, open the Horizon console for `web-1`, log in as `ubuntu` with password `openstack`, and run the following command:

```bash
# stop Apache on the first backend while leaving the VM running
sudo systemctl stop apache2
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm from the console that the Apache service is no longer active
systemctl is-active apache2
```

??? example "Expected result"
    ```bash
    inactive
    ```

```bash
# confirm that the Apache service on the first backend no longer answers locally
curl -sS --max-time 5 http://127.0.0.1/
```

??? example "Expected result"
    ```bash
    curl: (7) Failed to connect to 127.0.0.1 port 80 after 0 ms: Connection refused
    ```

!!! note
    Return to `Project > Network > Load Balancers` and inspect the `demo-pool` member list. With a `PING` monitor, `web-1` can still appear healthy because the VM is reachable even though the Apache application has stopped.

```bash
# send repeated HTTP requests through the VIP while one backend application is down
for i in {1..6}; do curl -s --max-time 5 http://<vip-floating-ip>/ || printf 'request failed'; printf '\n'; done
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

**12.4.14 Start Apache Again Before Replacing the Health Monitor**

Use the `web-1` Horizon console again and run:

```bash
# start Apache on the first backend again
sudo systemctl start apache2
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm locally that the first backend Apache page responds again
curl -s http://127.0.0.1/
```

??? example "Expected result"
    ```bash
    <h1>Apache backend web-1</h1>
    ```

**12.4.15 Replace the PING Monitor with an HTTP Monitor**

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

**12.4.16 Stop Apache on web-1 Again and Verify That HTTP Monitoring Protects the Service**

Use the `web-1` Horizon console again and run:

```bash
# stop Apache on the first backend again to trigger the HTTP monitor
sudo systemctl stop apache2
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
for i in {1..6}; do curl -s --max-time 5 http://<vip-floating-ip>/; printf '\n'; done
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

**12.4.17 Restore the Failed Backend After the Demo**

Use the `web-1` Horizon console again and run:

```bash
# start Apache on the first backend so both members can return to service
sudo systemctl start apache2
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# confirm locally that the first backend health endpoint responds again
curl -s http://127.0.0.1/healthcheck
```

??? example "Expected result"
    ```bash
    OK
    ```

!!! note
    After the demo, give the HTTP monitor enough time to probe `web-1` again. The member should return to a healthy or online state in Horizon and the VIP should resume serving both backends over time.

**12.4.18 Optional Cleanup**

1. From `Project > Network > Load Balancers`, delete `demo-lb` and confirm the cascade delete of its child resources if Horizon prompts for it.
2. From `Project > Compute > Instances`, delete `web-1` and `web-2`.
3. From `Project > Network > Floating IPs`, release the floating IP address used by the VIP.
4. Wait until the instances, floating IP associations, and load balancer resources are removed.
