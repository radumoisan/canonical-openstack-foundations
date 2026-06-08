# 12.1 Appendix A: Recover from Total Outage

If the cluster experiences a complete outage, some services may remain degraded after the nodes return. This appendix covers the manual recovery steps that may still be required.

Two services need manual intervention in this scenario: `mysql-innodb-cluster` and `vault`.

**12.1.1 Recover the Database Cluster**

Check the status of the database charm. It should be unhealthy after a full outage.

```bash
# Check the mysql-innodb-cluster status
juju status mysql-innodb-cluster
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.5.2    unsupported  06:08:29-05:00

    App                   Version  Status   Scale  Charm                 Channel       Exposed  Rev  OS      Notes
    mysql-innodb-cluster  8.0.37   blocked      3  mysql-innodb-cluster  8.0/stable    no       133  ubuntu

    Unit                     Workload  Agent  Machine  Public address  Ports  Message
    mysql-innodb-cluster/0   blocked   idle   0/lxd/3  192.168.100.54         MySQL InnoDB Cluster not healthy: None
    mysql-innodb-cluster/1*  blocked   idle   1/lxd/2  192.168.100.46         MySQL InnoDB Cluster not healthy: None
    mysql-innodb-cluster/2   blocked   idle   2/lxd/2  192.168.100.52         MySQL InnoDB Cluster not healthy: None

    Machine  State    DNS             Inst id              Base           AZ       Message
    0        started  192.168.100.37  os-compute01         ubuntu@22.04   default  Deployed
    0/lxd/3  started  192.168.100.54  juju-3da275-0-lxd-3  ubuntu@22.04   default  Container started
    1        started  192.168.100.38  os-compute02         ubuntu@22.04   default  Deployed
    1/lxd/2  started  192.168.100.46  juju-3da275-1-lxd-2  ubuntu@22.04   default  Container started
    2        started  192.168.100.39  os-compute03         ubuntu@22.04   default  Deployed
    2/lxd/2  started  192.168.100.52  juju-3da275-2-lxd-2  ubuntu@22.04   default  Container started
    ```

List the available Juju actions for `mysql-innodb-cluster`. Look for `reboot-cluster-from-complete-outage`.

```bash
# List mysql-innodb-cluster recovery actions
juju actions mysql-innodb-cluster
```

??? example "Expected result"
    ```bash
    reboot-cluster-from-complete-outage  Reboot the cluster from this instance's GTID superset after a complete outage.
    ```

Run this action on the leader unit of the charm.

```bash
# Run the complete-outage recovery action on the leader
juju run mysql-innodb-cluster/leader reboot-cluster-from-complete-outage --wait 15m
```

??? example "Expected result"
    ```bash
    Action completed successfully.
    ```

Wait a few minutes for this process to finish and check the cluster status again.

```bash
# Re-check the mysql-innodb-cluster status
juju status mysql-innodb-cluster
```

??? example "Expected result"
    ```bash
    Look for the mysql-innodb-cluster units to return to a healthy state.
    ```

**12.1.2 Unseal Vault**

The Vault charm may need to be unsealed after a complete cluster restart. In this lab, Vault was deployed with `totally-unsecure-auto-unlock`, which is suitable only for testing and not for production.

Check the status of the Vault charm.

```bash
# Check the vault charm status
juju status vault
```

??? example "Expected result"
    ```bash
    Look for vault to report a degraded, blocked, or waiting state before recovery.
    ```

The Vault process inside the LXD container may need a restart after the database is healthy again.

```bash
# Check the vault systemd service state
juju exec --unit vault/0 sudo systemctl status vault
```

??? example "Expected result"
    ```bash
    Look for the vault service state and any recent database connectivity errors.
    ```

```bash
# Restart the vault systemd service
juju exec --unit vault/0 sudo systemctl restart vault
```

??? example "Expected result"
    ```bash
    No output.
    ```

Install the Vault client.

```bash
# Install the Vault CLI client
sudo snap install vault
```

??? example "Expected result"
    ```bash
    vault <channel> from HashiCorp installed
    ```

Now get the unseal key. In a production deployment, Vault typically requires multiple unseal keys. In this lab configuration, a single key is sufficient.

```bash
# Retrieve the Vault leader data and locate the unseal key
juju exec --unit vault/0 leader-get
```

??? example "Expected result"
    ```bash
    keys: '["[REDACTED]"]'
    ```

Unseal Vault using the keys from the file.

```bash
# Export the VAULT_ADDR environment variable
export VAULT_ADDR="http://$(juju exec --unit vault/leader unit-get private-address):8200"
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Unseal Vault with the recovery key
vault operator unseal <unseal key 1>
```

??? example "Expected result"
    ```bash
    Key                Value
    ---                -----
    Sealed             false
    ```

Authorize the vault charm.

```bash
# Export the Vault root token from the saved state file
export VAULT_TOKEN=$(cat /home/ubuntu/vault-state.txt | grep "Initial Root Token" | awk '{print $4}')
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Create a short-lived token for charm authorization
CHARM_TOKEN=$(vault token create -ttl=10m | egrep "^token\s+" | awk '{print $2}')
```

??? example "Expected result"
    ```bash
    No output.
    ```

```bash
# Authorize the vault charm with the generated token
juju run --wait 5m vault/leader authorize-charm token=$CHARM_TOKEN
```

??? example "Expected result"
    ```bash
    Action completed successfully.
    ```

Resolve the Vault charm if it is in error state.

```bash
# Resolve the vault unit if it remains in error
juju resolved vault/0
```

??? example "Expected result"
    ```bash
    No output.
    ```

Wait a few minutes for the charm to become active again.

Check the status of the charm.

```bash
# Check the overall model status after Vault recovery
juju status
```

??? example "Expected result"
    ```bash
    Model  Controller       Cloud/Region  Version  SLA          Timestamp
    uos    maas-controller  maas/default  3.5.2    unsupported  13:43:39Z

    App                 Version  Status  Scale  Charm         Channel     Rev  Exposed  Message
    vault               1.7.9    active      1  vault         1.7/stable  349  no       Unit is ready (active: true, mlock: disabled)
    vault-mysql-router  8.0.37   active      1  mysql-router  8.0/stable  200  no       Unit is ready

    Unit                     Workload  Agent  Machine  Public address  Ports     Message
    vault/0*                 active    idle   3/lxd/3  192.168.100.26  8200/tcp  Unit is ready (active: true, mlock: disabled)
      vault-mysql-router/0*  active    idle            192.168.100.26            Unit is ready

    Machine  State    Address         Inst id              Base          AZ       Message
    3        started  192.168.100.24  os-compute04         ubuntu@22.04  default  Deployed
    3/lxd/3  started  192.168.100.26  juju-c06005-3-lxd-3  ubuntu@22.04   default  Container started
    ```
