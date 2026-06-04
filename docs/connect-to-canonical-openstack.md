# 1. Connect to your Canonical OpenStack

The Canonical Openstack will be provided in the cloud. Here it 
is explained how to connect to it.


## 1.1 SSH connection

### Task 1: Create the SSH Tunnel

On `Linux`:

Use the terminal:
```bash
ssh -D 9999 ubuntu@<your public IP>
```

Please note the `-D 9999`. This is a socks proxy. It is used
to access internal UI services of the cloud for, like MAAS and JUJU.


On `Windows` open `Putty`:

1) In the `Session` section, add the `public IP address` you 
received on mail from the trainer, port should be 22.

2) On the left side, go to `Connection > SSH > Tunnels`

3) In `Source Port` enter `9999`, select `Dynamic` button, 
and click `Add`.

4) Go back to `Session` section, add a name in `Saved Sessions` and click `Save`.


### Task 2: Set the proxy in browser

Because it's a `SOCKS` proxy, we need to set it in the browser.
`Firefox` will be demonstrated here.


1) Go to `Preferences` or `Options` icon.

2) Navigate to `Network Settings`.

3) Select `Manual proxy configuration`, use `localhost` or
`127.0.0.1` for the `SOCKS host` with port `9999`. Click `OK` when done.

For `Chrome`, the proxy settings can be configured from the Operating System 
networking configurations,, the proxy settings can be configured from the Operating System 
networking configurations, e.g. LAN Settings on Windows. 

