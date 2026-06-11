# 1. Prerequisites

The Canonical OpenStack will be provided in the cloud. Here it 
is explained how to connect to it.


## :material-book-open-page-variant-outline: 1.1 SSH connection

**1.1.1 Create the SSH Tunnel**

On `Linux`:

Use the terminal:
```bash
ssh -D 9999 ubuntu@<your public IP>
```

!!! note
    `-D 9999` creates a local SOCKS proxy on port `9999`.
    Use it to access internal UI services of the lab environment, such as
    MAAS and Juju.


On `Windows` open `Putty`:

1) In the `Session` section, add the `public IP address` you 
received on mail from the trainer, port should be 22.

2) On the left side, go to `Connection > SSH > Tunnels`

3) In `Source Port` enter `9999`, select `Dynamic` button, 
and click `Add`.

4) Go back to `Session` section, add a name in `Saved Sessions` and click `Save`.


**1.1.2 Set the proxy in browser**

Because this is a `SOCKS` proxy, configure it in the browser.
`Firefox` is used here.


1) Open `Settings` in Firefox.

2) Search for `network` and open `Network Settings`.

3) Select `Manual proxy configuration`.

4) Set `SOCKS Host` to `127.0.0.1` and port `9999`.

5) Keep `SOCKS v5` selected.

6) Click `OK`.

This browser configuration is used later to access services running on the
target environment through the SSH tunnel. Do not expect MAAS or other
internal web interfaces to be reachable yet. The first concrete validation of
this proxy path happens after the MAAS server is installed and initialized in
Chapter 2.

For `Chrome`, the proxy settings can be configured from the operating system
network settings, for example via LAN Settings on Windows.

## :material-book-open-page-variant-outline: 1.2 Training Resources

The following lab files are published with the site so you can download them as
needed during the training.

!!! warning
    These files are provided for this training environment exactly as requested.
    Some files contain lab-specific defaults, passwords, or credential-bearing
    configuration and should be treated as lab-only assets.

**Deployment assets**

- [`cloud-init.iso`](downloads/openstack_files/deploy/cloud-init.iso): Cloud-init ISO used during local VM creation.
- [`cloud.xml`](downloads/openstack_files/deploy/cloud.xml): Libvirt domain definition template for the lab VM.
- [`create-vms.sh`](downloads/openstack_files/deploy/create-vms.sh): Script that creates the local lab VMs.
- [`destroy-vms.sh`](downloads/openstack_files/deploy/destroy-vms.sh): Script that removes the local lab VMs.
- [`meta-data`](downloads/openstack_files/deploy/meta-data): Cloud-init metadata file.
- [`network-config`](downloads/openstack_files/deploy/network-config): Cloud-init network configuration file.
- [`user-data`](downloads/openstack_files/deploy/user-data): Cloud-init user-data file for VM initialization.

**OpenStack and Juju assets**

- [`admin_openrc`](downloads/openstack_files/os_files/admin_openrc): Wrapper that selects the appropriate admin OpenStack RC settings.
- [`admin_openrcv3_project`](downloads/openstack_files/os_files/admin_openrcv3_project): Keystone v3 admin environment file.
- [`glance-simplestreams-sync.yaml`](downloads/openstack_files/os_files/glance-simplestreams-sync.yaml): Juju config for `glance-simplestreams-sync`.
- [`init_vault.sh`](downloads/openstack_files/os_files/init_vault.sh): Helper script to authorize the Vault charm.
- [`labvars.sh`](downloads/openstack_files/os_files/labvars.sh): Lab-wide environment variable definitions.
- [`landscape_bundle.yaml`](downloads/openstack_files/os_files/landscape_bundle.yaml): Juju bundle for the Landscape deployment.
- [`maas.yaml`](downloads/openstack_files/os_files/maas.yaml): Juju cloud definition for MAAS.
- [`my-config.yaml`](downloads/openstack_files/os_files/my-config.yaml): Juju bootstrap configuration for the OpenStack controller.
- [`my-openstack.yaml`](downloads/openstack_files/os_files/my-openstack.yaml): Juju cloud definition for the OpenStack provider.
- [`openstack-bundle.yaml`](downloads/openstack_files/os_files/openstack-bundle.yaml): Main Juju bundle used to deploy OpenStack.
- [`student_openrc`](downloads/openstack_files/os_files/student_openrc): Wrapper that selects the appropriate student OpenStack RC settings.
- [`student_openrcv3_project`](downloads/openstack_files/os_files/student_openrcv3_project): Keystone v3 student environment file.

**Provisioning script**

- [`provision_maas.sh`](downloads/openstack_files/provision_maas.sh): Script used to provision the MAAS lab host.
