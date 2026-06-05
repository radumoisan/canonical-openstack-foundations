# 3. Install and Configure Juju

**Description:**

In this section, you install and configure Juju and integrate it with MAAS.

## :material-book-open-page-variant-outline: 3.1 Install the Juju Client


**Description:**

In this exercise, you install Juju on the MAAS server using the recommended way with snaps.

**Note:** You can also use the distribution package of juju, but going forward,
the recommended way to deploy juju is using the `juju snap` from 
the snap store which will always give you the latest stable version 
independent of the underlying operating system version.


**3.1.1 Install the Juju Client on the MAAS Server**

On the `MAAS server`, open a terminal window and enter the following commands:

```bash
sudo snap install juju --channel=3.6/stable --devmode
```


## :material-book-open-page-variant-outline: 3.2 Bootstrap Juju for MAAS


**Description:**

In this exercise, you will deploy (bootstrap) the Juju state service utilizing MAAS.


**3.2.1 Configure Juju for MAAS**

**Important:**

When editing a `.yaml` file, spacing and indentation is important. Make sure you use spaces instead of tabs and that you indent new entries to match the other entries in the section you are adding to.

On the MAAS server, enter the following to see the MAAS cloud configuration file for Juju. The ```~/os_files/maas.yaml``` already exists.

```bash
cat ~/os_files/maas.yaml
# output
clouds:
  maas:
    type: maas
    auth-types: [oauth1]
    endpoint: http://192.168.100.3:5240/MAAS/
```

Run the following command to load the MAAS cloud configuration file into Juju:

```bash
juju add-cloud maas ~/os_files/maas.yaml
```

List the clouds available to Juju:

```bash
juju list-clouds
```

Display the contents of the file `~/maas-apikey`:


```bash
cat ~/maas-apikey
```

Create the credentials file Juju will use to authenticate with MAAS:

```bash
juju add-credential maas
```

When prompted by the previous command, enter the following values:
> `credential name`: **admin**
> `Select region`: **Leave blank**
> ``maas-oauth``: **MAAS API key (from step 4)**


Verify the maas-oauth value in `~/.local/share/juju/credentials.yaml` matches the contents of the `~/maas-apikey` file you created earlier. We will call this key **MAAS_API_KEY**.

```bash
cat ~/.local/share/juju/credentials.yaml

cat ~/maas-apikey
```

List all credentials currently configured for Juju:

```bash
juju list-credentials
```

**3.2.2 Bootstrap the Juju System**

Enter the following command to view the status of Juju:

```bash
juju status
```
> You should get an error because the Juju system has not been bootstrapped.


Enter the following commands to bootstrap Juju:

```bash
juju bootstrap --config default-base="ubuntu@22.04" \
  --bootstrap-constraints="mem=2G cores=1" \
  --constraints="mem=2G tags=juju" \
  maas maas-controller
```

> (this command will take a while to complete because it is installing the OS
> and Juju service on the VM os-juju01)

**Note:** For this command to work, you must have previously created the `juju` tag 
and added the node os-juju01 to the tag. When the command completes, you should 
see an output similar to:

```bash
Creating Juju controller "maas-controller" on maas/default
Looking for packaged Juju agent version 3.6.2 for amd64
Located Juju agent version 3.6.2-ubuntu-amd64 at https://streams.canonical.com/juju/tools/agent/3.6.2/juju-3.6.2-linux-amd64.tgz
Launching controller instance(s) on maas/default...
 - fspqar (arch=amd64 mem=2G cores=2)
Installing Juju agent on bootstrap instance
Waiting for address
Attempting to connect to 192.168.100.10:22
Connected to 192.168.100.10
Running machine configuration script...
Bootstrap agent now started
Contacting Juju controller at 192.168.100.10 to verify accessibility...

Bootstrap complete, controller "maas-controller" is now available
Controller machines are in the "controller" model

Now you can run
	juju add-model <model-name>
to create a new model to deploy workloads.
```

Enter the following command again to view the status of the default model for the MAAS cloud in Juju:

```bash
juju status -m controller
```

>  You should see output showing that the default model for the MAAS cloud is ready. It will look similar to:


```bash
Model       Controller       Cloud/Region  Version  SLA          Timestamp
controller  maas-controller  maas/default  3.6.2    unsupported  13:16:11Z

App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
controller           active      1  juju-controller  3.6/stable  116  no

Unit           Workload  Agent  Machine  Public address  Ports  Message
controller/0*  active    idle   0        192.168.100.10

Machine  State    Address         Inst id    Base          AZ       Message
0        started  192.168.100.10  os-juju01  ubuntu@22.04  default  Deployed
```

## :material-book-open-page-variant-outline: 3.3 Access Juju GUI


**Description:**

In this exercise you will use the juju command to deploy the dashboard and then access it.


**3.3.1 Deploy Juju Dashboard**

1. On the MAAS server, enter the following commands to install and expose Juju Dashboard:

```bash
juju switch controller
juju deploy juju-dashboard dashboard --to=lxd:0
juju integrate dashboard controller
juju expose dashboard
```

2. Wait for the dashboard to be deployed:

```bash
watch -c juju status -m controller --color
```

3. Once dashboard is installed, On MAAS server, run the following command to get the Juju authentication credentials:

```bash
juju dashboard --browser=false
```

Output will be like:

```bash
Dashboard for controller "maas-controller" is enabled at:
  http://localhost:31666
Your login credential is:
  username: admin
  password: 26c3e05096d30b2eff652b1fad5a27a3
```

This command will open a tunnel to your dashboard, but we're not going to use it. Instead, username and password will be useful in this case. 
To get the IP address of your dashboard unit, either Ctrl+C in your current terminal or in a new terminal connected to your MAAS server, run:

```bash
juju show-unit dashboard/0 --format yaml | grep public-address| cut -f 2 -d ":" | awk '{print $1}'
```

4. Open a web browser on the student workstation and point to the address of
   the Juju Dashboard unit with port 8080. E.g. http://192.168.100.11:8080 and use the information provided in the output of the `juju dashboard` command above to log in.


## :material-book-open-page-variant-outline: 3.4 Use juju ssh to Connect to a Node


**Description:**

In this exercise, you use the `juju ssh` and `juju scp` commands to connect to
and copy files to a Juju deployed machine.


**3.4.1 List the existing Juju models**

In a terminal on the MAAS server enter the following to list the current
models available to the Juju controller:

```bash
juju models
# output
Controller: maas-controller

Model        Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
controller*  maas/default  maas  available         2      2  2      admin   just now
```

**3.4.2 Use juju ssh**

In a terminal on the MAAS server enter the following command to connect via
SSH to the Juju controller node:

```bash
juju ssh -m controller 0
```

> You should be logged into the node os-juju01.

Enter the following command to disconnect:

```bash
exit
```

> You should be back on the MAAS server.

**3.4.3 Use juju scp**

Enter the following command to copy a file via scp to the Juju controller node:

```bash
juju scp -m controller /etc/services 0:/tmp
```

Enter the following command to connect via ssh to the Juju controller node:

```bash
juju ssh -m controller 0 -- ls -al /tmp
```
> You should be logged into the node os-juju01 and getting file listing of remote /tmp folder.

> You should see the services file. You can also verify its contents remotely:

```bash
juju ssh -m controller 0 -- cat /tmp/services
```

> You should see the contents of the services file.


