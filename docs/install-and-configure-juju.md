# 3. Install and Configure Juju

**Description:**

In this section, you install and configure Juju and integrate it with MAAS.

## :material-book-open-page-variant-outline: 3.1 Install the Juju Client

**Description:**

In this exercise, you install Juju on the MAAS server using the recommended way
with snaps.

!!! note
    You can also use the distribution package of Juju, but the recommended way
    to deploy Juju is using the `juju` snap from the snap store. This keeps the
    Juju client aligned with the current stable release stream.

**3.1.1 Install the Juju Client on the MAAS Server**

On the `MAAS server`, install the Juju snap:

```bash
# install the Juju snap
sudo snap install juju --channel=3.6/stable --devmode
```

??? example "Expected result"
    ```bash
    juju (3.6/stable) 3.6.23 from Canonical** installed
    ```

## :material-book-open-page-variant-outline: 3.2 Bootstrap Juju for MAAS

**Description:**

In this exercise, you bootstrap the Juju state service using MAAS.

**3.2.1 Configure Juju for MAAS**

!!! note
    When editing a `.yaml` file, spacing and indentation matter. Use spaces
    instead of tabs and keep new entries aligned with the existing structure.

On the MAAS server, view the MAAS cloud definition that Juju will use. The file
`~/os_files/maas.yaml` already exists.

```bash
# show the MAAS cloud definition for Juju
cat ~/os_files/maas.yaml
```

??? example "Expected result"
    ```bash
    clouds:
      maas:
        type: maas
        auth-types: [oauth1]
        endpoint: http://192.168.100.3:5240/MAAS/
    ```

Load the MAAS cloud configuration into the local Juju client:

```bash
# add the MAAS cloud to the local Juju client
juju add-cloud maas ~/os_files/maas.yaml --client
```

??? example "Expected result"
    ```bash
    Cloud "maas" successfully added to your local client.
    ```

List the clouds available to Juju:

```bash
# list the Juju clouds
juju list-clouds
```

??? example "Expected result"
    ```bash
    Clouds available on the controller:
    Cloud  Regions  Default  Type
    maas   1        default  maas

    Clouds available on the client:
    Cloud      Regions  Default    Type  Credentials  Source    Description
    localhost  1        localhost  lxd   0            built-in  LXD Container Hypervisor
    maas       1        default    maas  1            local     Metal As A Service
    Only clouds with registered credentials are shown.
    There are more clouds, use --all to see them.
    ```

Display the contents of the file `~/maas-apikey`:

```bash
# show the MAAS API key
cat ~/maas-apikey
```

??? example "Expected result"
    ```bash
    [redacted-maas-api-key]
    ```

Create the credentials file Juju will use to authenticate with MAAS:

```bash
# create the Juju MAAS credentials file
cat > ~/.local/share/juju/credentials.yaml <<EOF
credentials:
  maas:
    admin:
      auth-type: oauth1
      maas-oauth: $(cat ~/maas-apikey)
EOF
```

??? example "Expected result"
    ```bash
    No output.
    ```

Verify the contents of the credentials file:

```bash
# show the Juju credentials file
cat ~/.local/share/juju/credentials.yaml
```

??? example "Expected result"
    ```bash
    credentials:
      maas:
        admin:
          auth-type: oauth1
          maas-oauth: [redacted-maas-api-key]
    ```

List all credentials currently configured for Juju:

```bash
# list the Juju credentials
juju list-credentials
```

??? example "Expected result"
    ```bash
    Controller Credentials:
    Cloud  Credentials
    maas   admin

    Client Credentials:
    Cloud  Credentials
    maas   admin
    ```

**3.2.2 Bootstrap the Juju System**

View the status of Juju before bootstrapping:

```bash
# check the Juju status before bootstrap
juju status
```

??? example "Expected result"
    ```bash
    ERROR No controllers registered.
    ```

Bootstrap Juju on MAAS:

```bash
# bootstrap the Juju controller on the Juju-tagged MAAS machine
juju bootstrap --config default-base="ubuntu@22.04" \
  --bootstrap-constraints="mem=2G cores=1" \
  --constraints="mem=2G tags=juju" \
  maas maas-controller
```

??? example "Expected result"
    ```bash
    Creating Juju controller "maas-controller" on maas/default
    Looking for packaged Juju agent version 3.6.23 for amd64
    Launching controller instance(s) on maas/default...
     - hyedet (arch=amd64 mem=2G cores=2)
    Installing Juju agent on bootstrap instance
    Waiting for address
    Attempting to connect to 192.168.100.10:22
    Connected to 192.168.100.10
    Running machine configuration script...
    Bootstrap agent now started
    Contacting Juju controller at 192.168.100.10 to verify accessibility...

    Bootstrap complete, controller "maas-controller" is now available
    Controller machines are in the "controller" model
    ```

!!! note
    This command takes a while to complete because it installs the operating
    system and Juju controller service on `os-juju01`.

View the status of the controller model after bootstrap:

```bash
# show the Juju controller model status
juju status -m controller
```

??? example "Expected result"
    ```bash
    Model       Controller       Cloud/Region  Version  SLA          Timestamp
    controller  maas-controller  maas/default  3.6.23   unsupported  13:32:49Z

    App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
    controller           active      1  juju-controller  3.6/stable  230  yes

    Unit           Workload  Agent  Machine  Public address  Ports            Message
    controller/0*  active    idle   0        192.168.100.10  17022,17070/tcp

    Machine  State    Address         Inst id    Base          AZ       Message
    0        started  192.168.100.10  os-juju01  ubuntu@22.04  default
    ```

## :material-book-open-page-variant-outline: 3.3 Access Juju GUI

**Description:**

In this exercise, you deploy the Juju dashboard and collect the access details.

**3.3.1 Deploy Juju Dashboard**

Switch to the controller model:

```bash
# switch to the Juju controller model
juju switch controller
```

??? example "Expected result"
    ```bash
    maas-controller (controller) -> maas-controller:admin/controller
    ```

Deploy the Juju dashboard:

```bash
# deploy the Juju dashboard charm
juju deploy juju-dashboard dashboard --to=lxd:0
```

??? example "Expected result"
    ```bash
    Deployed "dashboard" from charm-hub charm "juju-dashboard", revision 61 in channel 0.15/stable on ubuntu@22.04/stable
    ```

Integrate the dashboard with the controller:

```bash
# integrate the dashboard with the controller
juju integrate dashboard controller
```

??? example "Expected result"
    ```bash
    No output.
    ```

Expose the dashboard service:

```bash
# expose the dashboard service
juju expose dashboard
```

??? example "Expected result"
    ```bash
    No output.
    ```

Check the dashboard status until it becomes `active` and `idle`:

```bash
# check the dashboard status
juju status -m controller dashboard
```

??? example "Expected result"
    ```bash
    Model       Controller       Cloud/Region  Version  SLA          Timestamp
    controller  maas-controller  maas/default  3.6.23   unsupported  13:41:53Z

    App        Version  Status  Scale  Charm           Channel      Rev  Exposed  Message
    dashboard           active      1  juju-dashboard  0.15/stable   61  yes

    Unit          Workload  Agent  Machine  Public address  Ports     Message
    dashboard/0*  active    idle   0/lxd/0  192.168.100.11  8080/tcp

    Machine  State    Address         Inst id              Base          AZ       Message
    0        started  192.168.100.10  os-juju01            ubuntu@22.04  default  Deployed
    0/lxd/0  started  192.168.100.11  juju-f46aea-0-lxd-0  ubuntu@22.04  default  Container started
    ```

Display the Juju dashboard login details:

```bash
# print the Juju dashboard login details
juju dashboard --browser=false
```

??? example "Expected result"
    ```bash
    Dashboard for controller "maas-controller" is enabled at:
      http://localhost:31666
    Your login credential is:
      username: admin
      password: [redacted-dashboard-password]
    ```

!!! note
    This command keeps a local tunnel open. If you only need the credentials,
    copy them and then press `Ctrl+C`.

Retrieve the dashboard unit IP address:

```bash
# get the Juju dashboard unit IP address
juju show-unit dashboard/0 --format yaml | grep public-address | cut -f 2 -d ":" | awk '{print $1}'
```

??? example "Expected result"
    ```bash
    192.168.100.11
    ```

Open a web browser on the student workstation and point to the dashboard unit
address on port `8080`, for example `http://192.168.100.11:8080`. Use the
credentials returned by `juju dashboard --browser=false` to log in.

## :material-book-open-page-variant-outline: 3.4 Use Juju SSH to Connect to a Node

**Description:**

In this exercise, you use the `juju ssh` and `juju scp` commands to connect to
and copy files to a Juju-managed machine.

**3.4.1 List the Existing Juju Models**

List the models available to the Juju controller:

```bash
# list the Juju models
juju models
```

??? example "Expected result"
    ```bash
    Controller: maas-controller

    Model        Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
    controller*  maas/default  maas  available         2      2  2      admin   just now
    ```

**3.4.2 Verify Juju SSH Access**

Confirm you can reach the Juju controller node over `juju ssh`:

```bash
# confirm Juju SSH access to the controller node
juju ssh -m controller 0 -- hostname
```

??? example "Expected result"
    ```bash
    os-juju01
    ```

**3.4.3 Use Juju SCP**

Copy a file to the Juju controller node:

```bash
# copy /etc/services to the controller node
juju scp -m controller /etc/services 0:/tmp
```

??? example "Expected result"
    ```bash
    No output.
    ```

Verify that the file exists on the remote node:

```bash
# list the remote /tmp directory on the controller node
juju ssh -m controller 0 -- ls -al /tmp
```

??? example "Expected result"
    ```bash
    total 64
    drwxrwxrwt 12 root   root    4096 Jun  5 13:42 .
    drwxr-xr-x 19 root   root    4096 Jun  5 13:31 ..
    drwxrwxrwt  2 root   root    4096 Jun  5 13:31 .ICE-unix
    drwxrwxrwt  2 root   root    4096 Jun  5 13:31 .Test-unix
    drwxrwxrwt  2 root   root    4096 Jun  5 13:31 .X11-unix
    drwxrwxrwt  2 root   root    4096 Jun  5 13:31 .XIM-unix
    drwxrwxrwt  2 root   root    4096 Jun  5 13:31 .font-unix
    -rw-------  1 root   root       0 Jun  5 13:32 juju-machine-lock
    -rw-r--r--  1 ubuntu ubuntu 12813 Jun  5 13:40 services
    ```

Show the copied file contents on the remote node:

```bash
# show the copied /tmp/services file on the controller node
juju ssh -m controller 0 -- cat /tmp/services
```

??? example "Expected result"
    ```bash
    # Network services, Internet style
    #
    # Updated from https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml .
    #
    # New ports will be added on request if they have been officially assigned
    # by IANA and used in the real-world or are needed by a debian package.
    # If you need a huge list of used numbers please install the nmap package.

    tcpmux         1/tcp                 # TCP port service multiplexer
    echo           7/tcp
    echo           7/udp
    discard        9/tcp         sink null
    discard        9/udp         sink null
    systat         11/tcp        users
    daytime        13/tcp
    daytime        13/udp
    netstat        15/tcp
    qotd           17/tcp        quote
    chargen        19/tcp        ttytst source
    chargen        19/udp        ttytst source
    ...
    ```
