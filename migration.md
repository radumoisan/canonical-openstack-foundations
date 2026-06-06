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

## Stage 1: Site Migration

Purpose: create the OpenStack Foundations MkDocs structure from the source document.

Planned work:

1. Update `mkdocs.yml` site metadata for OpenStack Foundations.
2. Replace the old Ubuntu Advanced navigation with OpenStack Foundations chapters.
3. Create one Markdown file under `docs/` for each top-level chapter.
4. Preserve the chapter order from `openstack_foundation_lab.md`.
5. Keep appendices as a dedicated page without renumbering the source content.
6. Keep `openstack_foundation_lab.md` unchanged.
7. Mark migrated chapters as `Migrated`, not `Complete`.

## Stage 1 Chapter Targets

### 1. Prerequisites

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 1
- Target page: `docs/connect-to-canonical-openstack.md`
- Validation note: `1.1 SSH connection` has been started on student host `34.159.9.11`.
- Validation note: Firefox SOCKS proxy setup is verified locally and was later used successfully to access internal lab web interfaces.

### 2. Install and Configure MAAS

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 2
- Target page: `docs/install-and-configure-maas.md`
- Validation note: Chapter 2 validation started on student host `34.159.9.11`.
- Validation note: The MAAS VM image was recovered by replacing a corrupted guest image with a clean reprovisioned VM before continuing command validation.
- Validation note: The Chapter 2 Web UI section was reviewed and reorganized as an alternative path to the validated CLI workflow.

### 3. Install and Configure Juju

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 3
- Target page: `docs/install-and-configure-juju.md`
- Validation note: Chapter 3 validation started on student host `34.159.9.11`.
- Validation note: Juju `3.6.23` was installed on the MAAS VM and controller `maas-controller` was bootstrapped on `os-juju01`.
- Validation note: Juju dashboard deployment, `juju ssh`, and `juju scp` were validated against the controller model.
- Validation note: The Juju dashboard browser login was validated at `http://192.168.100.11:8080` through the SOCKS proxy path.

### 4. Juju Charms

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 4
- Target page: `docs/juju-charms.md`
- Validation note: Chapter 4 model creation and Landscape deployment were validated on the MAAS VM from student host `34.159.9.11`.
- Validation note: The Landscape bundle reached `active` status with HAProxy exposed on `192.168.100.18` during validation.
- Validation note: The cleanup flow to destroy the `landscape` model and `maas-controller` was validated and then executed as the transition into Chapter 5.
- Validation note: During intermediate demo validation, the Juju dashboard was redeployed on the controller model and validated at `http://192.168.100.21:8080` before the final Chapter 4 teardown.

### 5. Deploy OpenStack

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 5
- Target page: `docs/deploy-openstack-with-juju-and-maas.md`
- Validation note: Chapter 5 was validated from the MAAS VM after the Chapter 4 controller teardown on student host `34.159.9.11`.
- Validation note: A fresh `maas-controller` was bootstrapped on `os-juju01` at `192.168.100.22` and model `uos` was created for the OpenStack deployment.
- Validation note: The OpenStack bundle deployed successfully with all 27 applications reaching `active` status.
- Validation note: Ceph health checks returned `HEALTH_OK`, the Horizon dashboard was reachable at `http://192.168.100.35/horizon`, and the OpenStack CLI validated service catalog and endpoint access.
- Validation note: Interactive monitoring and browser steps were preserved in the training content but validated non-interactively during live execution.

### 6. Work with Software Defined Networks

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 6
- Target page: `docs/software-defined-networks.md`
- Validation note: Chapter 6 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: External network `Public_Network` and subnet `Public_Subnet` were created successfully on `physnet1` with MTU `1300`.
- Validation note: The validated subnet uses `192.168.100.0/24` with floating IP allocation pool `192.168.100.150-192.168.100.199` and DHCP disabled.
- Validation note: Horizon remained reachable at `http://192.168.100.35/horizon` and returned HTTP `302` for an unauthenticated request.

### 7. Work with Cloud Images

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 7
- Target page: `docs/cloud-images.md`
- Validation note: Chapter 7 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: The Ubuntu Jammy minimal cloud image was downloaded successfully and converted from `qcow2` to `raw` as `~/cloud_images/ubuntu-jammy.img`.
- Validation note: Glance image `jammy` was uploaded successfully with minimum disk `3`, visibility `public`, and architecture `x86_64`.
- Validation note: The uploaded image reached `active` status on the Ceph-backed Glance store.

### 8. Configure an OpenStack Project

- Status: `Complete`
- Source range: `openstack_foundation_lab.md` chapter 8
- Target page: `docs/configure-openstack-project.md`
- Validation note: Chapter 8 was validated from the MAAS VM on student host `34.159.9.11`.
- Validation note: The `openstack project create` command required argument reordering: `--domain admin_domain` must appear before the project name positional argument.
- Validation note: The `openstack quota set` command emits a deprecation warning about `--force` defaulting for network quotas; this does not affect the outcome.
- Validation note: All CLI commands in sections 8.1 through 8.8 were validated successfully.
- Validation note: The Web UI section (8.9) was reviewed and reorganized as an alternative path to the validated CLI workflow.

### 9. Work with Cloud Workload Instances

- Status: `Migrated`
- Source range: `openstack_foundation_lab.md` chapter 9
- Target page: `docs/cloud-workload-instances.md`

### 10. Work with OpenStack Storage

- Status: `Migrated`
- Source range: `openstack_foundation_lab.md` chapter 10
- Target page: `docs/openstack-storage.md`

### 11. Configure Juju to Use OpenStack as a Provider

- Status: `Migrated`
- Source range: `openstack_foundation_lab.md` chapter 11
- Target page: `docs/juju-openstack-provider.md`

### Appendices

- Status: `Migrated`
- Source range: `openstack_foundation_lab.md` chapter 13
- Target page: `docs/appendices.md`
- Note: the source skips chapter 12; do not renumber appendices during migration.

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
- Prerequisites: `connect-to-canonical-openstack.md`
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
- Appendices: `appendices.md`

## Notes

- Stage 1 does not prove command correctness.
- Stage 1 should avoid changing technical meaning.
- Stage 2 is where command outputs, environmental corrections, and happy-path results are captured.
- The source uses inconsistent casing such as `Openstack`; migrated pages should use `OpenStack` in headings and prose where appropriate.
