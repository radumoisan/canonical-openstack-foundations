# 4. Juju Charms

**Description:**

In this section, we will deploy `Landscape Server` application together with all of its dependencies.

## :material-book-open-page-variant-outline: 4.1 Create Model for application deployment

### :material-book-open-page-variant-outline: Task 1: List the existing models associated with the MAAS controller

In a terminal on the MAAS server, as the `ubuntu`, enter the
following to list the current models available to the Juju controller:

```bash
juju models

# output
Controller: maas-controller

Model        Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
controller*  maas/default  maas  available         2      2  2      admin   just now
```

> The model name with the asterisk is the active model for the current (active) controller.


### :material-book-open-page-variant-outline: Task 2: Create a model named landscape

In a terminal on the MAAS server, as the `ubuntu`, enter the following to create the model landscape:

```bash
juju add-model landscape

# output
Added 'landscape' model on maas/default with credential 'admin' for user 'admin'
```

### :material-book-open-page-variant-outline: Task 3: Set the default series for the new model

In a terminal on the MAAS server, as the `ubuntu`,enter the following to set the default base for the model `landscape`:

```bash
juju model-config -m landscape default-base=ubuntu@22.04
```

### :material-book-open-page-variant-outline: Task 4: Verify the new model

In a terminal on the MAAS server, as the `ubuntu`, enter the following to verify the model `landscape` has been created:

```bash
juju models

# output
Controller: maas-controller

Model       Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
controller  maas/default  maas  available         2      2  2      admin   just now
landscape*  maas/default  maas  available         0      -  -      admin   8 seconds ago
```

Enter to following to verify the default-series value for the model `landscape`:

```bash
juju model-config default-base

# output
ubuntu@22.04
```


## :material-book-open-page-variant-outline: 4.2 Deploy applications

### :material-book-open-page-variant-outline: Task 1: Deploy Landscape Scalable bundle

Check the existing juju model, there should be one called `landscape`:

```bash
juju models
```

In this model, deploy the `landscape-scalable` bundle:

```bash
juju deploy landscape-scalable
```

Watch for the completion of the bundle deployment:
```bash
watch -c juju status --color
```

### :material-book-open-page-variant-outline: Task 2: Verify the deployment

Run the following command that will also reaveal relations between applications:

```bash
juju status --relations

# output
Model      Controller       Cloud/Region  Version  SLA          Timestamp
landscape  maas-controller  maas/default  3.5.1    unsupported  12:38:52Z

App               Version  Status  Scale  Charm             Channel        Rev  Exposed  Message
haproxy                    active      1  haproxy           latest/stable   75  yes      Unit is ready
landscape-server           active      1  landscape-server  latest/stable  107  no       Unit is ready
postgresql        14.12    active      1  postgresql        latest/stable  345  no       Live master (14.12)
rabbitmq-server   3.9.13   active      1  rabbitmq-server   3.9/stable     188  no       Unit is ready

Unit                 Workload  Agent  Machine  Public address  Ports           Message
haproxy/0*           active    idle   0        192.168.100.12  80,443/tcp      Unit is ready
landscape-server/0*  active    idle   1        192.168.100.13                  Unit is ready
postgresql/0*        active    idle   2        192.168.100.15  5432/tcp        Live master (14.12)
rabbitmq-server/0*   active    idle   3        192.168.100.14  5672,15672/tcp  Unit is ready

Machine  State    Address         Inst id       Base          AZ       Message
0        started  192.168.100.12  os-compute01  ubuntu@22.04  default  Deployed
1        started  192.168.100.13  os-compute02  ubuntu@22.04  default  Deployed
2        started  192.168.100.15  os-compute03  ubuntu@22.04  default  Deployed
3        started  192.168.100.14  os-compute04  ubuntu@22.04  default  Deployed

Integration provider       Requirer                   Interface          Type     Message
haproxy:peer               haproxy:peer               haproxy-peer       peer
landscape-server:replicas  landscape-server:replicas  landscape-replica  peer
landscape-server:website   haproxy:reverseproxy       http               regular
postgresql:coordinator     postgresql:coordinator     coordinator        peer
postgresql:db-admin        landscape-server:db        pgsql              regular
postgresql:replication     postgresql:replication     pgpeer             peer
rabbitmq-server:amqp       landscape-server:amqp      rabbitmq           regular
rabbitmq-server:cluster    rabbitmq-server:cluster    rabbitmq-ha        peer
```

### :material-book-open-page-variant-outline: Task 3: Log in to Landscape Web interface

Get the IP address of the HAProxy unit:

```bash
juju status haproxy

# output
Model      Controller       Cloud/Region  Version  SLA          Timestamp
landscape  maas-controller  maas/default  3.5.1    unsupported  12:39:53Z

App      Version  Status  Scale  Charm    Channel        Rev  Exposed  Message
haproxy           active      1  haproxy  latest/stable   75  yes      Unit is ready

Unit        Workload  Agent  Machine  Public address  Ports       Message
haproxy/0*  active    idle   0        **192.168.100.12**  80,443/tcp  Unit is ready

Machine  State    Address         Inst id       Base          AZ       Message
0        started  **192.168.100.12**  os-compute01  ubuntu@22.04  default  Deployed
```

My IP is `192.168.100.12`, so the URL will be `https://192.168.100.12`.

Use Firefox to access that IP. You can configure the initial user of Landscape and gain access to its management console.


### :material-book-open-page-variant-outline: Task 4: Remove the landscape model

Remove the `landscape` juju model. This will remove any charms/applications that are contained in it.

```bash
juju destroy-model --no-prompt landscape
```

List and destroy the juju controller.

```bash
juju controllers
```

```bash
juju destroy-controller maas-controller --no-prompt
```
