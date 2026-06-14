# Migration Tracker

This file tracks the migration of the MkDocs site from Ubuntu Server Advanced to OpenStack Foundations.

## Source Of Truth

`openstack_foundation_lab.md` is the source reference for the OpenStack Foundations training.

Keep the source file unchanged.

## Migration Goal

Convert the monolithic `openstack_foundation_lab.md` source into a MkDocs documentation site with one page per top-level chapter.

The first stage is a content migration only.

The second stage is live validation: run the lab commands on the target machine, capture the happy-path results, and update the chapter pages based on observed output.

## Status Model

- `Not started`: no chapter page has been created yet.
- `Migrated`: chapter content has been moved into `docs/`, but commands have not been validated.
- `In review`: chapter is being validated step by step on the target environment.
- `Complete`: all commands in the chapter have been validated and expected results have been documented.

## Completion Rule

A chapter can be marked `Complete` only after all of these are true:

- Every command in the chapter has been executed successfully in the lab environment.
- Expected results have been updated from real or representative successful output.
- Any environment-specific corrections discovered during validation have been incorporated.
- The chapter still preserves the technical meaning of the source material.

Exception: the appendix pages under `docs/appendix_a.md`, `docs/appendix_b.md`, and `docs/appendix_c.md` are reference material and may be marked `Complete` after a documentation review pass when live validation is explicitly out of scope.

## Stage 1: Site Migration

Purpose: create the OpenStack Foundations MkDocs structure from the source document.

Planned work:

1. Update `mkdocs.yml` site metadata for OpenStack Foundations.
2. Replace the old Ubuntu Advanced navigation with OpenStack Foundations chapters.
3. Create one Markdown file under `docs/` for each top-level chapter.
4. Preserve the chapter order from `openstack_foundation_lab.md`.
5. Keep appendices as a dedicated page while leaving the source file unchanged.
6. Keep `openstack_foundation_lab.md` unchanged.
7. Mark migrated chapters as `Migrated`, not `Complete`.

## Stage 1 Chapter Targets

### 1. Prerequisites

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 1
- Target page: `docs/prerequisites.md`
- Validation note: `1.1 SSH connection` has been started on student host `34.159.9.11`.
- Validation note: Firefox SOCKS proxy setup is verified locally and was later used successfully to access internal lab web interfaces.
- Validation note: Chapter 1 SSH tunnel validation succeeded on clean student host `34.40.48.14` using a background SOCKS tunnel on local port `9999`; browser setup was skipped for the CLI-only unattended run.

### 2. Install and Configure MAAS

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 2
- Target page: `docs/install-and-configure-maas.md`
- Validation note: Chapter 2 validation started on student host `34.159.9.11`.
- Validation note: The MAAS VM image was recovered by replacing a corrupted guest image with a clean reprovisioned VM before continuing command validation.
- Validation note: The Chapter 2 Web UI section was reviewed and reorganized as an alternative path to the validated CLI workflow.
- Validation note: Chapter 2 was revalidated on clean student host `34.40.48.14`; MAAS VM `192.168.100.3` reached a `36G` root filesystem after resize, MAAS `3.4.9` initialized successfully, and all five lab nodes reached `Ready`.
- Validation note: `os-juju01` was tagged `juju`; `os-compute01` through `os-compute04` were tagged `storage`.
- Validation note: The clean host required installing `jq` on the MAAS VM and starting the newly created `os-*` libvirt domains before MAAS chassis enlistment discovered them.

### 3. Install and Configure Juju

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 3
- Target page: `docs/install-and-configure-juju.md`
- Validation note: Chapter 3 validation started on student host `34.159.9.11`.
- Validation note: Juju `3.6.23` was installed on the MAAS VM and controller `maas-controller` was bootstrapped on `os-juju01`.
- Validation note: Juju dashboard deployment, `juju ssh`, and `juju scp` were validated against the controller model.
- Validation note: The Juju dashboard browser login was validated at `http://192.168.100.11:8080` through the SOCKS proxy path.
- Validation note: Chapter 3 was revalidated on clean student host `34.40.48.14`; Juju `3.6.23` bootstrapped `maas-controller` on `os-juju01` at `192.168.100.10`.
- Validation note: Juju dashboard reached `active` on `192.168.100.11:8080`; browser login was skipped for the CLI-only unattended run.
- Validation note: `juju ssh`, `juju scp`, and copied-file verification succeeded against the controller model.

### 4. Juju Charms

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 4
- Target page: `docs/juju-charms.md`
- Validation note: Chapter 4 model creation and Landscape deployment were validated on the MAAS VM from student host `34.159.9.11`.
- Validation note: The Landscape bundle reached `active` status with HAProxy exposed on `192.168.100.18` during validation.
- Validation note: The cleanup flow to destroy the `landscape` model and `maas-controller` was validated and then executed as the transition into Chapter 5.
- Validation note: During intermediate demo validation, the Juju dashboard was redeployed on the controller model and validated at `http://192.168.100.21:8080` before the final Chapter 4 teardown.
- Validation note: Chapter 4 was revalidated on clean student host `34.40.48.14`; the Landscape bundle reached `active` with HAProxy exposed at `192.168.100.12`.
- Validation note: The documented cleanup was executed; the `landscape` model was destroyed and `juju controllers` returned `ERROR No controllers registered.` after destroying `maas-controller`.

### 5. Deploy OpenStack

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 5
- Target page: `docs/deploy-openstack-with-juju-and-maas.md`
- Validation note: Chapter 5 was validated from the MAAS VM after the Chapter 4 controller teardown on student host `34.159.9.11`.
- Validation note: A fresh `maas-controller` was bootstrapped on `os-juju01` at `192.168.100.22` and model `uos` was created for the OpenStack deployment.
- Validation note: The OpenStack bundle deployed successfully with all 27 applications reaching `active` status.
- Validation note: Ceph health checks returned `HEALTH_OK`, the Horizon dashboard was reachable at `http://192.168.100.35/horizon`, and the OpenStack CLI validated service catalog and endpoint access.
- Validation note: Interactive monitoring and browser steps were preserved in the training content but validated non-interactively during live execution.
- Validation note: Chapter 5 was revalidated on clean student host `34.40.48.14`; a fresh `maas-controller` bootstrapped on `os-juju01` at `192.168.100.16`.
- Validation note: The OpenStack bundle deployed successfully with all 27 applications reaching `active` status in model `uos`.
- Validation note: Ceph returned `HEALTH_OK`, OpenStack catalog and endpoint commands succeeded, and Horizon returned HTTP `302` at `http://192.168.100.22/horizon`.

### 6. Work with Software Defined Networks

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 6
- Target page: `docs/software-defined-networks.md`
- Validation note: Chapter 6 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: External network `Public_Network` and subnet `Public_Subnet` were created successfully on `physnet1` with MTU `1300`.
- Validation note: The validated subnet uses `192.168.100.0/24` with floating IP allocation pool `192.168.100.150-192.168.100.199` and DHCP disabled.
- Validation note: Horizon remained reachable at `http://192.168.100.35/horizon` and returned HTTP `302` for an unauthenticated request.
- Validation note: Chapter 6 was revalidated on clean student host `34.40.48.14`; `Public_Network` and `Public_Subnet` were created with the documented `physnet1`, flat provider, MTU `1300`, and floating IP allocation pool.
- Validation note: Horizon returned HTTP `302` at `http://192.168.100.22/horizon` after network creation.

### 7. Work with Cloud Images

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 7
- Target page: `docs/cloud-images.md`
- Validation note: Chapter 7 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: The Ubuntu Jammy minimal cloud image was downloaded successfully and converted from `qcow2` to `raw` as `~/cloud_images/ubuntu-jammy.img`.
- Validation note: Glance image `jammy` was uploaded successfully with minimum disk `3`, visibility `public`, and architecture `x86_64`.
- Validation note: The uploaded image reached `active` status on the Ceph-backed Glance store.
- Validation note: Chapter 7 was revalidated on clean student host `34.40.48.14`; image `jammy` uploaded as ID `85bafa79-7d2e-4280-86cf-46e220a53470` and reached `active` status.
- Validation note: The clean MAAS VM required installing `qemu-utils` before converting the downloaded Jammy qcow2 image to raw format.

### 8. Configure an OpenStack Project

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 8
- Target page: `docs/configure-openstack-project.md`
- Validation note: Chapter 8 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: The `openstack project create` command required argument reordering: `--domain admin_domain` must appear before the project name positional argument.
- Validation note: The `openstack quota set` command emits a deprecation warning about `--force` defaulting for network quotas; this does not affect the outcome.
- Validation note: All CLI commands in sections 8.1 through 8.8 were validated successfully.
- Validation note: The Web UI section (8.9) was reviewed and reorganized as an alternative path to the validated CLI workflow.
- Validation note: Chapter 8 was revalidated on clean student host `34.40.48.14`; `StudentProject` ID is `b41c5cc8e3644c109c9ed30cb03adaa2` and user `student` ID is `cd7f304259084c44a33d4d0425a5cd41`.
- Validation note: Keypairs, ICMP/SSH security groups, quotas, tenant network/subnet/router, and floating IP allocation completed successfully; allocated floating IP was `192.168.100.188`.

### 9. Work with Cloud Workload Instances

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 9
- Target page: `docs/cloud-workload-instances.md`
- Validation note: Chapter 9 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: The `openstack host list` command emits a deprecation warning suggesting `hypervisor list` instead; this does not affect the outcome.
- Validation note: The subshell pattern `$(openstack host list ... | awk ...)` used in the source for adding hosts to aggregates does not work in this environment due to nested shell quoting. Hosts were added by name directly.
- Validation note: The `juju exec` command for reading `DEFAULT_FILTERS` must be run directly on the MAAS VM, not inside a `bash -lc` subshell, since `juju` needs to be in the current shell PATH.
- Validation note: The `openstack server create` command requires the network ID to be provided directly rather than via a subshell lookup.
- Validation note: The `openstack server show jammy1 -c security_groups -f value` command returns security groups in compact JSON format rather than the full table shown in the source.
- Validation note: All CLI commands in sections 9.1 through 9.5 were validated successfully.
- Validation note: The Web UI section (9.6) was reviewed and reorganized as an alternative path to the validated CLI workflow.
- Validation note: Chapter 9 was revalidated on clean student host `34.40.48.14`; flavors `m1.smaller` and `kvm.smaller`, aggregate `kvm`, and scheduler filter configuration were validated.
- Validation note: Instance `jammy1` reached `ACTIVE` with fixed IP `10.20.30.59` and floating IP `192.168.100.188`; ICMP failed before adding the ICMP security group and succeeded after it was attached.

### 10. Work with OpenStack Storage

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 10
- Target page: `docs/openstack-storage.md`
- Validation note: Chapter 10 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: The `openstack volume create` command requires the name positional argument before `--description`. Placing the name after the description flag causes the name to be consumed as part of the description text, resulting in a volume with `name: None`.
- Validation note: The `openstack server add volume` command accepts the volume name directly; the subshell pattern `$(openstack volume list | grep volume1 | awk ...)` does not work reliably due to nested SSH quoting issues.
- Validation note: The `openstack server show` commands return fields in compact JSON format when using `-f value` (e.g., `volumes_attached` returns `[{'id': '...', 'delete_on_termination': False}]`).
- Validation note: The `openstack endpoint list` command with `-c "Service Type"` fails due to nested quoting issues with spaces in column names. The working form uses `--service object-store --interface public` filters instead.
- Validation note: The Swift public endpoint URL is `https://192.168.100.43/swift/v1`. The wget download requires `--ca-certificate=/home/ubuntu/snap/openstackclients/common/root-ca.crt`.
- Validation note: All CLI commands in sections 10.1 through 10.3 were validated successfully.
- Validation note: The Web UI section (10.4) was reviewed and reorganized as an alternative path to the validated CLI workflow.
- Validation note: Chapter 10 was revalidated on clean student host `34.40.48.14`; volume `volume1` ID `1f01698e-ee63-4b83-acc1-bbac584c2fc8` attached to `jammy1` as `/dev/vdb` and reached `in-use` status.
- Validation note: Swift container `mydata` was created with `myfile01.txt` and `myfile02.txt`; public object download from `https://192.168.100.28/swift/v1/mydata/myfile02.txt` succeeded using the OpenStack clients CA certificate.

### 11. Configure Juju to Use OpenStack as a Provider

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 11
- Target page: `docs/juju-openstack-provider.md`
- Validation note: Chapter 11 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: The `glance-simplestreams-sync` charm deployed successfully on machine 3/lxd in the `uos` model and synced images to Swift.
- Validation note: The interactive `juju add-cloud` and `juju add-credential` commands were replaced with non-interactive YAML file equivalents. The credential requires `tenant-name`, `user-domain-name`, and `project-domain-name` fields for Keystone v3 authentication.
- Validation note: The `juju bootstrap` on OpenStack requires `ssl-hostname-verification: false` in the bootstrap config because the lab uses a self-signed CA. The bootstrap takes around 15 minutes.
- Validation note: The `juju add-model` command also requires `ssl-hostname-verification=false` as model config, otherwise it fails with a TLS verification error.
- Validation note: The Landscape bundle deployed successfully with all 4 machines reaching `started` state. HAProxy reached `active` status within 10 minutes.
- Validation note: The `juju destroy-controller` command takes a significant amount of time because it must terminate all OpenStack instances (controller VM + 4 bundle VMs).

### 12. Appendices

- Status: `In review`
- Source range: `openstack_foundation_lab.md` chapter 13
- Target pages: `docs/appendix_a.md`, `docs/appendix_b.md`, `docs/appendix_c.md`, `docs/appendix_d.md`
- Review note: The source skips chapter 12. The derived site publishes Appendices as Chapter 12 for consistent navigation while keeping the source file unchanged.
- Review note: Appendix A was reviewed and reformatted as reference recovery guidance. Live validation was not required for this page by request.
- Review note: Appendix D is a derived Horizon-only Octavia exercise that extends the training beyond the source material.
- Validation note: Appendix D still requires live validation on an Octavia-enabled lab deployment before it can be marked `Complete`.

## Stage 2: Lab Validation

Purpose: validate the migrated documentation against the real target machine and capture the successful path.

Validation workflow:

1. Work one chapter at a time.
2. Work one lab step at a time.
3. Run commands on the target machine only when explicitly proceeding with validation.
4. Record only successful training commands in `commands.md`.
5. Do not record exploratory, failed, or corrected commands in `commands.md`.
6. Update each command's expected result using real successful output or close representative output.
7. Update the chapter content when the real environment requires clarification.
8. Mark subchapters as validated as they are completed.
9. Mark the chapter `Complete` only after all commands and expected results are validated.

## MkDocs Target Navigation

- Home: `index.md`
- Prerequisites: `prerequisites.md`
- Install and Configure MAAS: `install-and-configure-maas.md`
- Install and Configure Juju: `install-and-configure-juju.md`
- Juju Charms: `juju-charms.md`
- Deploy OpenStack: `deploy-openstack-with-juju-and-maas.md`
- Software Defined Networks: `software-defined-networks.md`
- Cloud Images: `cloud-images.md`
- Configure an OpenStack Project: `configure-openstack-project.md`
- Cloud Workload Instances: `cloud-workload-instances.md`
- OpenStack Storage: `openstack-storage.md`
- Juju OpenStack Provider: `juju-openstack-provider.md`
- Appendix A: `appendix_a.md`
- Appendix B: `appendix_b.md`
- Appendix C: `appendix_c.md`
- Appendix D: `appendix_d.md`

## Notes

- Stage 1 does not prove command correctness.
- Stage 1 should avoid changing technical meaning.
- Stage 2 is where command outputs, environmental corrections, and happy-path results are captured.
- The source uses inconsistent casing such as `Openstack`; migrated pages should use `OpenStack` in headings and prose where appropriate.
