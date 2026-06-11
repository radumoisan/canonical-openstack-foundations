#!/bin/bash

export VAULT_ADDR="http://$(juju run --unit vault/leader unit-get private-address):8200"

vault operator init -key-shares=5 -key-threshold=3 > /home/ubuntu/vault-state.txt

for i in `seq 1 3`; do
    KEY=$(cat /home/ubuntu/vault-state.txt | grep "Unseal Key $i" | awk '{print $4}')
    vault operator unseal $KEY
done

export VAULT_TOKEN=$(cat /home/ubuntu/vault-state.txt | grep "Initial Root Token" | awk '{print $4}')

CHARM_TOKEN=$(vault token create -ttl=10m | egrep "^token\s+" | awk '{print $2}')
juju run-action --wait vault/leader authorize-charm token=$CHARM_TOKEN