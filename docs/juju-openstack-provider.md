# 11. Configure Juju to Use OpenStack as a Provider

**Description:**

In this section, you configure Juju to use OpenStack as a provider. You then use
Juju to deploy services onto the OpenStack cloud.


## :material-book-open-page-variant-outline: 11.1 Generate Simplestreams Metadata for a Private Cloud

**Description:**

In this exercise, you use Juju to deploy `glance-simplestreams-sync` charm to provide
the cloud images to be used in a private OpenStack cloud.


### :material-book-open-page-variant-outline: Task 1: Inspect the YAML file for Glance Simplestreams Sync

In a terminal on the MAAS server the `~/os_files/glance-simplestreams-sync.yaml` file
already exists, just inspect the file:

```bash
cat ~/os_files/glance-simplestreams-sync.yaml
# output
glance-simplestreams-sync:
  use_swift: True
  run: True
  frequency: hourly
  region: RegionOne
  image_import_conversion: True
  snap-channel: 'latest/edge'
  mirror_list: '[{url: "https://cloud-images.ubuntu.com/releases/", name_prefix: "ubuntu:released"...
```


### :material-book-open-page-variant-outline: Task 2: Deploy Glance Simplestreams Sync

Enter the following command to deploy `Glance Simplestreams Sync`:

```bash
juju deploy --to=lxd:3 --base ubuntu@22.04 \
  --config ~/os_files/glance-simplestreams-sync.yaml \
  --channel 2024.1/stable \
  glance-simplestreams-sync
```

**Note:** You need to deploy with the `jammy` series as it's the one compatible with `OpenStack Caracal` release.

Add the relation from Glance Simplestreams Sync to Keystone (authentication and authorization) and Vault (certificates) with:

```bash
juju integrate glance-simplestreams-sync keystone
juju integrate glance-simplestreams-sync vault
```

You can use the following command to view the status of the charm deployment:

```bash
watch -c juju status glance-simplestreams-sync --color
```


## :material-book-open-page-variant-outline: 11.2 Configure Juju to Use OpenStack as a Provider

**Description:**

In this exercise, you configure Juju to manage a project in a private OpenStack
cloud.

### :material-book-open-page-variant-outline: Task 1: Create the cloud my-openstack

On the MAAS server run the following to have environment variables set:

```bash
source ~/student_openrc
```

Then, add the cloud definition for your OpenStack cloud by running the following:

```bash
juju add-cloud --client
```

When prompted enter the following values:
> `Select cloud type:`: **openstack**<br/>
> `Enter a name for your openstack cloud:`: **my-openstack**<br/>
> `Enter the API endpoint url for the cloud`: **https://192.168.100.xxx:5000/v3**<br/>
> `Enter a path to the CA certificate for your cloud if one is required to access it [/tmp/root-ca.crt]`: **Leave as it is**<br/>
> `Select one or more auth types separated by commas`: **userpass**<br/>
> `Enter region [RegionOne]`: **Leave blank**<br/>
> `Enter the API endpoint url for the region [use cloud api url]`: **Leave blank**<br/>
> `Enter another region? (y/N)`: **N**<br/>

On the MAAS server, add the credentials for the newly added cloud my-openstack
by running the following:

```bash
juju add-credential my-openstack --client
```

When prompted enter the following values:
> `Enter credential name`: **student**<br/>
> `Select region`: **Leave blank**<br/>
> `Enter username`: **student**<br/>
> `Enter password`: **openstack**<br/>
> `Enter tenant-name`: **StudentProject**<br/>
> `Enter tenant-id (optional)`: **Leave blank**<br/>
> `Enter version (optional)`: **3**<br/>
> `Enter domain-name (optional):`: **Leave blank**<br/>
> `Enter project-domain-name (optional):`: **admin_domain**<br/>
> `Enter user-domain-name (optional):`: **admin_domain**<br/>
>
> Leave the rest of the fields blank.
> 
> You should see output similar to the following:
> ```console
> Credential "student" added locally for cloud "my-openstack".
> ```


### :material-book-open-page-variant-outline: Task 2: Create the configuration file used for bootstrapping

Retrieve the product-streams public URL with the following:

```bash
source ~/admin_openrc

openstack endpoint list --service product-streams -f json | \
  jq -r '.[] | select(.Interface=="public").URL'
```

We will refer to this value as the SWIFT_URL

On the MAAS server, the file named `~/os_files/my-config.yaml` already exists.
Edit it in a text editor and replace the `XXX` with the IP from the previous command:   

Enter the following values in the file:

```bash
cat ~/os_files/my-config.yaml
# output
network: StudentProject_Network
external-network: Public_Network
image-metadata-url: https://192.168.100.XXX:443/swift/v1/simplestreams/data/
default-base: ubuntu@22.04
ssl-hostname-verification: false
```

Edit the file with the Swift URL:

```bash
vim ~/os_files/my-config.yaml
```



### :material-book-open-page-variant-outline: Task 3: Bootstrap Juju on OpenStack

Enter the following commands to allocate four floating IPs to the project:

```bash
source ~/student_openrc
```

```bash
openstack floating ip create Public_Network
openstack floating ip create Public_Network
openstack floating ip create Public_Network
openstack floating ip create Public_Network
```

Create a new flavor for the instances created with Juju:

```bash
source ~/admin_openrc
```

```bash
openstack flavor create --vcpus 2 --ram 2048 --disk 10 --ephemeral 0 \
  --swap 0 --public kvm.node
```

```bash
openstack flavor set --property \
  aggregate_instance_extra_specs:kvm=true kvm.node
```

Enter the following command to bootstrap Juju on the OpenStack cloud:

```bash
juju bootstrap --config ~/os_files/my-config.yaml \
  --bootstrap-constraints="mem=2G cores=2 allocate-public-ip=true" \
  --constraints="mem=2G" my-openstack my-controller
```

Bootstrapping the Juju controller inside OpenStack is going to take around 15 minutes.

When the juju bootstrap command has finished, enter the following command to
view the status of the Juju environment:

```bash
juju status -m controller
```

You should see that the environment is bootstrapped.




## :material-book-open-page-variant-outline: 11.3 Deploy a Landscape Bundle on OpenStack with Juju

**Description:**

In this exercise, you deploy an application bundle using Juju.


### :material-book-open-page-variant-outline: Task 1: Setup the cloud environment

At the terminal of the MAAS server, enter the following command to list the
available controllers:

```bash
juju controllers
```

The controller `my-controller` should be listed as the active controller (has
an asterisk next to the controller name)

If the controller `my-controller` is not listed as the active controller use
the following command to switch the controller:

```bash
juju switch my-controller
```

Enter the following command to view the status of the OpenStack Juju environment:

```bash
juju status -m controller
```


### :material-book-open-page-variant-outline: Task 2: Deploy the Landscape Application Bundle

On the MAAS server you should have the file
`~/os_files/landscape_bundle.yaml` file:

```bash
cat ~/os_files/landscape_bundle.yaml
# output
default-base: ubuntu@22.04/stable
applications:
  haproxy:
    charm: haproxy
    channel: latest/stable
    num_units: 1
    to:
    - "0"
    expose: true
    options:
      default_timeouts: queue 60000, connect 5000, client 120000, server 120000
      global_default_bind_options: no-tlsv10
      services: ""
      ssl_cert: SELFSIGNED
    constraints: arch=amd64
  landscape-server:
    charm: landscape-server
    channel: latest/stable
    num_units: 1
    to:
    - "1"
  postgresql:
    charm: postgresql
    channel: latest/stable
    num_units: 1
    to:
    - "2"
    options:
      extra_packages: python*-apt postgresql-contrib postgresql-.*-debversion postgresql-plpython.*
      max_connections: 500
      max_prepared_transactions: 500
    storage:
      pgdata: rootfs,5M
  rabbitmq-server:
    charm: rabbitmq-server
    channel: 3.9/stable
    num_units: 1
    to:
    - "3"
    options:
      consumer-timeout: 259200000
machines:
  "0":
    constraints: arch=amd64 instance-type=kvm.node
  "1":
    constraints: arch=amd64 instance-type=kvm.node
  "2":
    constraints: arch=amd64 instance-type=kvm.node
  "3":
    constraints: arch=amd64 instance-type=kvm.node
relations:
- - landscape-server:amqp
  - rabbitmq-server:amqp
- - landscape-server:website
  - haproxy:reverseproxy
- - landscape-server:db
  - postgresql:db-admin
```

Enter the following command to deploy the Landscape application bundle:

```bash
juju add-model landscape

juju set-model-constraints allocate-public-ip=true

juju deploy ./os_files/landscape_bundle.yaml
```

Deploying the bundle inside OpenStack will take around 30 minutes. Access the Landscape Web UI after the deployment finishes.

Enter the following command to monitor the deployment of the bundle:

```bash
watch -c juju status --color
```

You should see the applications defined in the bundle start to deploy.


After it's finished deploying, you can access Landscape Web UI by accessing the IP address of your HAProxy unit.
To find out the IP address of your HAProxy unit, run the following command:

```bash
juju status haproxy --format line | grep -v ^$ | awk '{print $3}' | head -1
```

### :material-book-open-page-variant-outline: Task 3: Remove the Landscape Application Bundle together with the controller

Remove the Juju controller managing OpenStack resources:

```bash
juju switch maas-controller
juju destroy-controller --destroy-all-models my-controller --no-prompt
```
