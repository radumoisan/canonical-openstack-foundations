# 11. Configure Juju to Use OpenStack as a Provider

**Description:**

In this section, you configure Juju to use OpenStack as a provider. You then use
Juju to deploy services onto the OpenStack cloud.

!!! note
    Chapter 11 requires the OpenStack cloud deployed in Chapters 5-10 to be fully operational, including the `uos` model on `maas-controller`, the `StudentProject` project, `Public_Network`, `kvm.node` flavor, and the `glance-simplestreams-sync` charm deployed in the `uos` model.


## :material-book-open-page-variant-outline: 11.1 Generate Simplestreams Metadata for a Private Cloud

**Description:**

In this exercise, you use Juju to deploy `glance-simplestreams-sync` charm to provide
the cloud images to be used in a private OpenStack cloud.

**11.1.1 Inspect the YAML file for Glance Simplestreams Sync**

In a terminal on the MAAS server the `~/os_files/glance-simplestreams-sync.yaml` file
already exists, just inspect the file:

```bash
# Inspect the glance-simplestreams-sync configuration file
cat ~/os_files/glance-simplestreams-sync.yaml
```

??? example "Expected result"
    ```bash
    glance-simplestreams-sync:
      use_swift: True
      run: True
      frequency: hourly
      region: RegionOne
      snap-channel: 'stable'
      mirror_list: '[{url: "https://cloud-images.ubuntu.com/releases/", name_prefix: "ubuntu:released", path: "streams/v1/index.sjson", max: 1, item_filters: ["release~(jammy)", "arch~(x86_64|amd64)", "ftype~(disk-kvm.img)"]}]'
    ```


**11.1.2 Deploy Glance Simplestreams Sync**

```bash
# Load the uos model context and deploy glance-simplestreams-sync
export JUJU_MODEL=uos
juju deploy --to=lxd:3 --base ubuntu@22.04 \
  --config ~/os_files/glance-simplestreams-sync.yaml \
  --channel 2024.1/stable \
  glance-simplestreams-sync
```

??? example "Expected result"
    ```bash
    Deployed "glance-simplestreams-sync" from charm-hub charm "glance-simplestreams-sync", revision 124 in channel 2024.1/stable on ubuntu@22.04/stable
    ```

!!! note
    The `--to=lxd:3` placement targets machine 3 in the `uos` model, which is one of the OpenStack compute nodes. The LXD container will be created on that machine.

```bash
# Relate glance-simplestreams-sync to keystone for authentication
juju integrate glance-simplestreams-sync keystone
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Relate glance-simplestreams-sync to vault for certificates
juju integrate glance-simplestreams-sync vault
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Monitor the charm deployment status
juju status glance-simplestreams-sync
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.6.23   unsupported  12:03:08Z

    App                        Version  Status  Scale  Charm                      Channel        Rev  Exposed  Message
    glance-simplestreams-sync           active      1  glance-simplestreams-sync  2024.1/stable  124  no       Unit is ready (Glance sync completed at 06/06/26 12:00:13, metadata uploaded to object store)

    Unit                          Workload  Agent  Machine  Public address  Ports  Message
    glance-simplestreams-sync/0*  active    idle   3/lxd/4  192.168.100.46         Unit is ready (Glance sync completed at 06/06/26 12:00:13, metadata uploaded to object store)

    Machine  State    Address         Inst id              Base          AZ       Message
    3        started  192.168.100.26  os-compute04         ubuntu@22.04  default  Deployed
    3/lxd/4  started  192.168.100.46  juju-ed0023-3-lxd-4  ubuntu@22.04  default  Container started
    ```

!!! note
    The glance-simplestreams-sync charm syncs cloud images and uploads the metadata to the Swift object store. The `product-streams` service endpoint becomes available in OpenStack after the sync completes.


## :material-book-open-page-variant-outline: 11.2 Configure Juju to Use OpenStack as a Provider

**Description:**

In this exercise, you configure Juju to manage a project in a private OpenStack
cloud.

**11.2.1 Create the cloud my-openstack**

On the MAAS server run the following to have environment variables set:

```bash
# Load the OpenStack student project environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

!!! note
    The interactive `juju add-cloud --client` and `juju add-credential my-openstack --client` commands require user input. The non-interactive equivalent using YAML files is shown below.

Create the cloud definition file:

```bash
# Create the my-openstack cloud YAML file
cat > ~/os_files/my-openstack.yaml << 'EOF'
clouds:
  my-openstack:
    type: openstack
    auth-types: [userpass]
    endpoint: https://192.168.100.29:5000/v3
    regions:
      RegionOne:
        endpoint: https://192.168.100.29:5000/v3
EOF
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Add the cloud definition to the local juju client
juju add-cloud --client my-openstack ~/os_files/my-openstack.yaml
```

??? example "Expected result"
    ```bash
    Cloud "my-openstack" successfully added to your local client.
    You will need to add a credential for this cloud (`juju add-credential my-openstack`)
    before you can use it to bootstrap a controller (`juju bootstrap my-openstack`) or
    to create a model (`juju add-model <your model name> my-openstack`).
    ```

On the MAAS server, add the credentials for the newly added cloud my-openstack
by running the following:

```bash
# Create the my-openstack credentials YAML file
cat > ~/os_files/my-openstack-creds.yaml << 'EOF'
credentials:
  my-openstack:
    student:
      auth-type: userpass
      username: student
      password: openstack
      tenant-name: StudentProject
      user-domain-name: admin_domain
      project-domain-name: admin_domain
EOF
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Add the credentials to the local juju client
juju add-credential my-openstack --client -f ~/os_files/my-openstack-creds.yaml
```

??? example "Expected result"
    ```bash
    Credential "student" added locally for cloud "my-openstack".
    ```

```bash
# Verify the cloud was added
juju clouds --all
```

??? example "Expected result"
    ```bash
    Only clouds with registered credentials are shown.
    There are more clouds, use --all to see them.
    You can bootstrap a new controller using one of these clouds...

    Clouds available on the client:
    Cloud         Regions  Default    Type       Credentials  Source    Description
    localhost     1        localhost  lxd        0            built-in  LXD Container Hypervisor
    maas          1        default    maas       1            local     Metal As A Service
    my-openstack  1        RegionOne  openstack  1            local     Openstack Cloud
    ```


**11.2.2 Create the configuration file used for bootstrapping**

Retrieve the product-streams public URL with the following:

```bash
# Load the admin environment and get the swift public endpoint
source ~/admin_openrc
openstack endpoint list --service swift --interface public -f value
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    393a8c74b7a94d63a0053163419b1054 RegionOne swift object-store True public https://192.168.100.43:443/swift/v1
    ```

!!! note
    The `product-streams` service is created by the `glance-simplestreams-sync` charm. The image metadata is stored in Swift, so the Swift public endpoint is used for the `image-metadata-url` configuration.

On the MAAS server, the file named `~/os_files/my-config.yaml` already exists.
Edit it in a text editor and replace the `XXX` with the IP from the previous command:

```bash
# Update my-config.yaml with the correct Swift URL
cat > ~/os_files/my-config.yaml << 'EOF'
network: StudentProject_Network
external-network: Public_Network
image-metadata-url: https://192.168.100.43:443/swift/v1/simplestreams/data/
default-base: ubuntu@22.04
ssl-hostname-verification: false
EOF
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Verify the configuration file
cat ~/os_files/my-config.yaml
```

??? example "Expected result"
    ```bash
    network: StudentProject_Network
    external-network: Public_Network
    image-metadata-url: https://192.168.100.43:443/swift/v1/simplestreams/data/
    default-base: ubuntu@22.04
    ssl-hostname-verification: false
    ```


**11.2.3 Bootstrap Juju on OpenStack**

```bash
# Load the OpenStack student project environment
source ~/student_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Allocate four floating IPs to the StudentProject
openstack floating ip create Public_Network
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | created_at          | 2026-06-06T12:05:04Z                 |
    | description         |                                      |
    | dns_domain          |                                      |
    | dns_name            |                                      |
    | fixed_ip_address    | None                                 |
    | floating_ip_address | 192.168.100.191                      |
    | floating_network_id | 0c7c4e22-a4ea-4454-b9b1-e5073c72c69b |
    | id                  | a51b633c-a428-4202-a0ee-a7ef1c73d507 |
    | name                | 192.168.100.191                      |
    | port_details        | None                                 |
    | port_id             | None                                 |
    | project_id          | 98b0c6176739443d827d4c51f88afcbe     |
    | qos_policy_id       | None                                 |
    | revision_number     | 0                                    |
    | router_id           | None                                 |
    | status              | DOWN                                 |
    | subnet_id           | None                                 |
    | tags                | []                                   |
    | updated_at          | 2026-06-06T12:05:04Z                 |
    +---------------------+--------------------------------------+
    ```

```bash
# Allocate a second floating IP
openstack floating ip create Public_Network
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | created_at          | 2026-06-06T12:05:21Z                 |
    | floating_ip_address | 192.168.100.166                      |
    | name                | 192.168.100.166                      |
    | status              | DOWN                                 |
    +---------------------+--------------------------------------+
    ```

```bash
# Allocate a third floating IP
openstack floating ip create Public_Network
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | created_at          | 2026-06-06T12:05:28Z                 |
    | floating_ip_address | 192.168.100.167                      |
    | name                | 192.168.100.167                      |
    | status              | DOWN                                 |
    +---------------------+--------------------------------------+
    ```

```bash
# Allocate a fourth floating IP
openstack floating ip create Public_Network
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | created_at          | 2026-06-06T12:05:35Z                 |
    | floating_ip_address | 192.168.100.154                      |
    | name                | 192.168.100.154                      |
    | status              | DOWN                                 |
    +---------------------+--------------------------------------+
    ```

Create a new flavor for the instances created with Juju:

```bash
# Load the OpenStack admin environment
source ~/admin_openrc
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Create the kvm.node flavor for Juju-managed instances
openstack flavor create --vcpus 2 --ram 2048 --disk 10 --ephemeral 0 \
  --swap 0 --public kvm.node
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    +----------------------------+--------------------------------------+
    | Field                      | Value                                |
    +----------------------------+--------------------------------------+
    | OS-FLV-DISABLED:disabled   | False                                |
    | OS-FLV-EXT-DATA:ephemeral  | 0                                    |
    | description                | None                                 |
    | disk                       | 10                                   |
    | id                         | a93bdc4b-d833-438e-b4bb-c16e85bc2169 |
    | name                       | kvm.node                             |
    | os-flavor-access:is_public | True                                 |
    | properties                 |                                      |
    | ram                        | 2048                                 |
    | rxtx_factor                | 1.0                                  |
    | swap                       | 0                                    |
    | vcpus                      | 2                                    |
    +----------------------------+--------------------------------------+
    ```

```bash
# Set the kvm aggregate property on the flavor
openstack flavor set --property \
  aggregate_instance_extra_specs:kvm=true kvm.node
```

??? example "Expected result"
    ```bash
    Using Keystone v3 API
    ```

```bash
# Bootstrap Juju controller on the OpenStack cloud
juju bootstrap --config ~/os_files/my-config.yaml \
  --bootstrap-constraints="mem=2G cores=2 allocate-public-ip=true" \
  --constraints="mem=2G" my-openstack my-controller
```

??? example "Expected result"
    ```bash
    Creating Juju controller "my-controller" on my-openstack/RegionOne
    ...
    Bootstrap complete, my-controller now available
    ```

!!! note
    Bootstrapping the Juju controller inside OpenStack takes around 15 minutes. The controller VM is created as an OpenStack instance with a floating IP assigned.

```bash
# View the status of the Juju controller model
juju status -m controller
```

??? example "Expected result"
    ```bash
    Model       Controller     Cloud/Region            Version  SLA          Timestamp
    controller  my-controller  my-openstack/RegionOne  3.6.23   unsupported  12:43:44Z

    App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
    controller           active      1  juju-controller  3.6/stable  230  yes

    Unit           Workload  Agent  Machine  Public address   Ports            Message
    controller/0*  active    idle   0        192.168.100.180  17022,17070/tcp

    Machine  State    Address          Inst id                               Base          AZ    Message
    0        started  192.168.100.180  45b4b8fa-3650-446f-a6c9-aca2e78be7ae  ubuntu@22.04  nova  ACTIVE
    ```


## :material-book-open-page-variant-outline: 11.3 Deploy a Landscape Bundle on OpenStack with Juju

**Description:**

In this exercise, you deploy an application bundle using Juju.

**11.3.1 Setup the cloud environment**

At the terminal of the MAAS server, enter the following command to list the
available controllers:

```bash
# List available Juju controllers
juju controllers
```

??? example "Expected result"
    ```bash
    Use --refresh option with this command to see the latest information.

    Controller       Model  User   Access     Cloud/Region            Models  Nodes    HA  Version
    maas-controller  uos    admin  superuser  maas/default                 2     25  none  3.6.23
    my-controller*   -      admin  superuser  my-openstack/RegionOne       1      1  none  3.6.23
    ```

The controller `my-controller` should be listed as the active controller (has
an asterisk next to the controller name).

If the controller `my-controller` is not listed as the active controller use
the following command to switch the controller:

```bash
# Switch to the my-controller if not already active
juju switch my-controller
```

??? example "Expected result"
    ```bash
    my-controller:admin/controller
    ```

```bash
# View the status of the OpenStack Juju environment
juju status -m controller
```

??? example "Expected result"
    ```bash
    Model       Controller     Cloud/Region            Version  SLA          Timestamp
    controller  my-controller  my-openstack/RegionOne  3.6.23   unsupported  12:43:44Z

    App         Version  Status  Scale  Charm            Channel     Rev  Exposed  Message
    controller           active      1  juju-controller  3.6/stable  230  yes

    Unit           Workload  Agent  Machine  Public address   Ports            Message
    controller/0*  active    idle   0        192.168.100.180  17022,17070/tcp

    Machine  State    Address          Inst id                               Base          AZ    Message
    0        started  192.168.100.180  45b4b8fa-3650-446f-a6c9-aca2e78be7ae  ubuntu@22.04  nova  ACTIVE
    ```


**11.3.2 Deploy the Landscape Application Bundle**

On the MAAS server you should have the file
`~/os_files/landscape_bundle.yaml` file:

```bash
# Inspect the landscape bundle YAML file
cat ~/os_files/landscape_bundle.yaml
```

??? example "Expected result"
    ```bash
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

```bash
# Create a new model for the Landscape deployment
juju add-model landscape --config ssl-hostname-verification=false
```

??? example "Expected result"
    ```bash
    Added 'landscape' model on my-openstack/RegionOne with credential 'student' for user 'admin'
    ```

!!! note
    The `ssl-hostname-verification=false` config is required because the OpenStack cloud uses a self-signed CA certificate. Without this, model creation fails with a TLS verification error.

```bash
# Set model constraints to allocate public IPs
juju set-model-constraints -m landscape allocate-public-ip=true
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Deploy the Landscape bundle
juju deploy -m landscape ./os_files/landscape_bundle.yaml
```

??? example "Expected result"
    ```bash
    Located charm "haproxy" in charm-hub, channel latest/stable
    Located charm "landscape-server" in charm-hub, channel latest/stable
    Located charm "postgresql" in charm-hub, channel latest/stable
    Located charm "rabbitmq-server" in charm-hub, channel 3.9/stable
    Executing changes:
    - upload charm haproxy from charm-hub for base ubuntu@22.04/stable from channel latest/stable with architecture=amd64
    - deploy application haproxy from charm-hub on ubuntu@22.04/stable with latest/stable
    - expose all endpoints of haproxy and allow access from CIDRs 0.0.0.0/0 and ::/0
    - upload charm landscape-server from charm-hub for base ubuntu@22.04/stable from channel latest/stable with architecture=amd64
    - deploy application landscape-server from charm-hub on ubuntu@22.04/stable with latest/stable
    - upload charm postgresql from charm-hub for base ubuntu@22.04/stable from channel latest/stable with architecture=amd64
    - deploy application postgresql from charm-hub on ubuntu@22.04/stable with latest/stable
      added resource wal-e
    - upload charm rabbitmq-server from charm-hub for base ubuntu@22.04/stable from channel 3.9/stable with architecture=amd64
    - deploy application rabbitmq-server from charm-hub on ubuntu@22.04/stable with 3.9/stable
    - add new machine 0
    - add new machine 1
    - add new machine 2
    - add new machine 3
    - add relation landscape-server:amqp - rabbitmq-server:amqp
    - add relation landscape-server:website - haproxy:reverseproxy
    - add relation landscape-server:db - postgresql:db-admin
    - add unit haproxy/0 to new machine 0
    - add unit landscape-server/0 to new machine 1
    - add unit postgresql/0 to new machine 2
    - add unit rabbitmq-server/0 to new machine 3
    Deploy of bundle completed.
    ```

!!! note
    Deploying the bundle inside OpenStack takes around 30 minutes. Four new VMs are created using the `kvm.node` flavor.

```bash
# Monitor the bundle deployment status
juju status -m landscape
```

??? example "Expected result"
    ```bash
    Model      Controller     Cloud/Region            Version  SLA          Timestamp
    landscape  my-controller  my-openstack/RegionOne  3.6.23   unsupported  12:55:19Z

    App               Version  Status       Scale  Charm             Channel        Rev  Exposed  Message
    haproxy                    active           1  haproxy           latest/stable  147  yes      Unit is ready
    landscape-server           maintenance      1  landscape-server  latest/stable  134  no       Installing apt packages
    postgresql                 waiting          1  postgresql        latest/stable  591  no       agent initialising
    rabbitmq-server            maintenance      1  rabbitmq-server   3.9/stable     295  no       installing charm software

    Unit                 Workload     Agent      Machine  Public address   Ports  Message
    haproxy/0*           active       idle       0        192.168.100.167         Unit is ready
    landscape-server/0*  maintenance  executing  1        192.168.100.191         (install) Installing apt packages
    postgresql/0*        waiting      executing  2        192.168.100.166         agent initialising
    rabbitmq-server/0*   maintenance  executing  3        192.168.100.154         (install) installing charm software

    Machine  State    Address          Inst id                               Base          AZ    Message
    0        started  192.168.100.167  c36a3b5a-2636-4ad8-9877-a9ce6cfc0f4f  ubuntu@22.04  nova  ACTIVE
    1        started  192.168.100.191  cd268ff1-84a7-4b50-b3cc-e3e68e08824e  ubuntu@22.04  nova  ACTIVE
    2        started  192.168.100.166  461f7af2-3c76-4e5c-91cb-5524bd263636  ubuntu@22.04  nova  ACTIVE
    3        started  192.168.100.154  7dfc4a6c-3be7-41da-8113-7f50b423a032  ubuntu@22.04  nova  ACTIVE
    ```

After it's finished deploying, you can access Landscape Web UI by accessing the IP address of your HAProxy unit.
To find out the IP address of your HAProxy unit, run the following command:

```bash
# Get the HAProxy unit IP address
juju status haproxy -m landscape --format line | grep -v ^$ | awk '{print $3}' | head -1
```

??? example "Expected result"
    ```bash
    192.168.100.167
    ```


**11.3.3 Remove the Landscape Application Bundle together with the controller**

Remove the Juju controller managing OpenStack resources:

```bash
# Switch back to the maas-controller
juju switch maas-controller
```

??? example "Expected result"
    ```bash
    my-controller:admin/landscape -> maas-controller:admin/uos
    ```

```bash
# Destroy the my-controller and all its models
juju destroy-controller --destroy-all-models my-controller --no-prompt
```

??? example "Expected result"
    ```bash
    WARNING This command will destroy the "my-controller" controller and all its resources
    Destroying controller
    Waiting for model resources to be reclaimed
    ...
    ```

!!! note
    The destroy-controller command takes a significant amount of time because it must terminate all OpenStack instances created by the controller (the controller VM itself plus the four Landscape bundle VMs). Wait for the command to complete before proceeding.
