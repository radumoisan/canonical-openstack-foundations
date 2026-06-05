# 1. Connect to your Canonical OpenStack

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
