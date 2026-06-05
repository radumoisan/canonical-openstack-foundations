# 4. Juju Charms

**Description:**

In this section, you deploy `Landscape Server` and its supporting applications.

## :material-book-open-page-variant-outline: 4.1 Create Model for application deployment

**4.1.1 List the existing models associated with the MAAS controller**

```bash
# List the models currently available on the controller
juju models
```

??? example "Expected result"
    ```bash
    Controller: maas-controller

    Model       Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
    controller  maas/default  maas  available         1      2  1      admin   just now
    ```

!!! note
    When more than one model is present, the active model is marked with an asterisk.

**4.1.2 Create a model named `landscape`**

```bash
# Create a new model for the Landscape deployment
juju add-model landscape
```

??? example "Expected result"
    ```bash
    Added 'landscape' model on maas/default with credential 'admin' for user 'admin'
    ```

**4.1.3 Set the default base for the new model**

```bash
# Set the default base for the landscape model
juju model-config -m landscape default-base=ubuntu@22.04
```

??? example "Expected result"
    ```bash
    No output.
    ```

**4.1.4 Verify the new model exists**

```bash
# Confirm that the landscape model was created and is active
juju models
```

??? example "Expected result"
    ```bash
    Controller: maas-controller

    Model       Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
    controller  maas/default  maas  available         1      2  1      admin   just now
    landscape*  maas/default  maas  available         0      -  -      admin   5 seconds ago
    ```

**4.1.5 Verify the default base**

```bash
# Verify the default base for the active model
juju model-config default-base
```

??? example "Expected result"
    ```bash
    ubuntu@22.04
    ```

## :material-book-open-page-variant-outline: 4.2 Deploy applications

**4.2.1 Deploy the `landscape-scalable` bundle**

Run the following commands in order to confirm the active model, start the deployment, and monitor it until all units are active.

```bash
# Confirm that the landscape model is available before deployment
juju models
```

??? example "Expected result"
    ```bash
    Controller: maas-controller

    Model       Cloud/Region  Type  Status     Machines  Cores  Units  Access  Last connection
    controller  maas/default  maas  available         1      2  1      admin   just now
    landscape*  maas/default  maas  available         0      -  -      admin   4 seconds ago
    ```

```bash
# Deploy the Landscape scalable bundle into the active model
juju deploy landscape-scalable
```

??? example "Expected result"
    ```bash
    Located bundle "landscape-scalable" in charm-hub, revision 37
    Located charm "haproxy" in charm-hub, channel latest/stable
    Located charm "landscape-server" in charm-hub, channel latest/stable
    Located charm "postgresql" in charm-hub, channel 14/stable
    Located charm "rabbitmq-server" in charm-hub, channel 3.9/stable
    Executing changes:
    - upload charm haproxy from charm-hub for base ubuntu@22.04/stable with revision 75 with architecture=amd64
    - deploy application haproxy from charm-hub on ubuntu@22.04/stable with stable
    - expose all endpoints of haproxy and allow access from CIDRs 0.0.0.0/0 and ::/0
    - upload charm landscape-server from charm-hub for base ubuntu@22.04/stable with revision 124 with architecture=amd64
    - deploy application landscape-server from charm-hub on ubuntu@22.04/stable with stable
    - upload charm postgresql from charm-hub for base ubuntu@22.04/stable with revision 468 with architecture=amd64
    - deploy application postgresql from charm-hub on ubuntu@22.04/stable with 14/stable
    - upload charm rabbitmq-server from charm-hub for base ubuntu@22.04/stable with revision 188 with architecture=amd64
    - deploy application rabbitmq-server from charm-hub on ubuntu@22.04/stable with 3.9/stable
    - add relation landscape-server - rabbitmq-server
    - add relation landscape-server - haproxy
    - add relation landscape-server:db - postgresql:db-admin
    - add unit haproxy/0 to new machine 0
    - add unit landscape-server/0 to new machine 1
    - add unit postgresql/0 to new machine 2
    - add unit rabbitmq-server/0 to new machine 3
    Deploy of bundle completed.
    ```

```bash
# Watch the deployment until all units become active
watch -c juju status --color
```

??? example "Expected result"
    ```bash
    - haproxy/0: 192.168.100.18 (agent:idle, workload:active) 80,443/tcp
    - landscape-server/0: 192.168.100.17 (agent:idle, workload:active)
    - postgresql/0: 192.168.100.20 (agent:idle, workload:active) 5432/tcp
    - rabbitmq-server/0: 192.168.100.19 (agent:idle, workload:active) 5672,15672/tcp
    ```

!!! note
    Press `Ctrl+C` to exit `watch` once all units show `active` status. During validation, the success signal was the condensed per-unit status shown above.

**4.2.2 Verify the deployment**

```bash
# Show application status together with charm relations
juju status --relations
```

??? example "Expected result"
    ```bash
    Model      Controller       Cloud/Region  Version  SLA          Timestamp
    landscape  maas-controller  maas/default  3.6.23   unsupported  15:22:09Z

    App               Version  Status  Scale  Charm             Channel        Rev  Exposed  Message
    haproxy                    active      1  haproxy           latest/stable   75  yes      Unit is ready
    landscape-server           active      1  landscape-server  latest/stable  124  no       Unit is ready
    postgresql        14.12    active      1  postgresql        14/stable      468  no
    rabbitmq-server   3.9.27   active      1  rabbitmq-server   3.9/stable     188  no       Unit is ready

    Unit                 Workload  Agent  Machine  Public address  Ports           Message
    haproxy/0*           active    idle   0        192.168.100.18  80,443/tcp      Unit is ready
    landscape-server/0*  active    idle   1        192.168.100.17                  Unit is ready
    postgresql/0*        active    idle   2        192.168.100.20  5432/tcp        Primary
    rabbitmq-server/0*   active    idle   3        192.168.100.19  5672,15672/tcp  Unit is ready

    Machine  State    Address         Inst id       Base          AZ       Message
    0        started  192.168.100.18  os-compute01  ubuntu@22.04  default  Deployed
    1        started  192.168.100.17  os-compute02  ubuntu@22.04  default  Deployed
    2        started  192.168.100.20  os-compute03  ubuntu@22.04  default  Deployed
    3        started  192.168.100.19  os-compute04  ubuntu@22.04  default  Deployed

    Integration provider       Requirer                   Interface          Type     Message
    haproxy:peer               haproxy:peer               haproxy-peer       peer
    landscape-server:replicas  landscape-server:replicas  landscape-replica  peer
    landscape-server:website   haproxy:reverseproxy       http               regular
    postgresql:database-peers  postgresql:database-peers  postgresql_peers   peer
    postgresql:db-admin        landscape-server:db        pgsql              regular
    postgresql:restart         postgresql:restart         rolling_op         peer
    postgresql:upgrade         postgresql:upgrade         upgrade            peer
    rabbitmq-server:amqp       landscape-server:amqp      rabbitmq           regular
    rabbitmq-server:cluster    rabbitmq-server:cluster    rabbitmq-ha        peer
    ```

**4.2.3 Log in to the Landscape web interface**

```bash
# Get the HAProxy unit address for the Landscape web entry point
juju status haproxy
```

??? example "Expected result"
    ```bash
    Model      Controller       Cloud/Region  Version  SLA          Timestamp
    landscape  maas-controller  maas/default  3.6.23   unsupported  15:22:16Z

    App      Version  Status  Scale  Charm    Channel        Rev  Exposed  Message
    haproxy           active      1  haproxy  latest/stable   75  yes      Unit is ready

    Unit        Workload  Agent  Machine  Public address  Ports       Message
    haproxy/0*  active    idle   0        192.168.100.18  80,443/tcp  Unit is ready

    Machine  State    Address         Inst id       Base          AZ       Message
    0        started  192.168.100.18  os-compute01  ubuntu@22.04  default  Deployed
    ```

Use the `Public address` value from the command output to reach Landscape. In this validation run, the URL was `http://192.168.100.18/`.

!!! note
    Firefox access to internal lab web interfaces was already validated through the SOCKS proxy path in earlier chapters.

**4.2.4 Remove the `landscape` model**

!!! note
    Skip this cleanup if you need to preserve the Landscape deployment for a demo. Chapter 5 re-bootstraps the controller after this teardown.

```bash
# Destroy the landscape model and all applications deployed into it
juju destroy-model --no-prompt landscape
```

??? example "Expected result"
    ```bash
    Model destroyed.
    ```

```bash
# List the registered Juju controllers before removing the controller
juju controllers
```

??? example "Expected result"
    ```bash
    Use --refresh option with this command to see the latest information.

    Controller        Model       User   Access     Cloud/Region  Models  Nodes    HA  Version
    maas-controller*  controller  admin  superuser  maas/default       1      1  none  3.6.23
    ```

```bash
# Destroy the MAAS-backed Juju controller
juju destroy-controller maas-controller --no-prompt
```

??? example "Expected result"
    ```bash
    All models reclaimed, cleaning up controller machines
    ```

```bash
# Verify that no Juju controllers remain registered locally
juju controllers
```

??? example "Expected result"
    ```bash
    ERROR No controllers registered.
    ```
