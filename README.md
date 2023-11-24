# OpenFOAM OnDemand App for Azure
This repository contains the app to run OpenFOAM+ on Azure AMD EPYC CPUs with OnDemand Portal

## Prerequisites

This application has been written with the following prerequisites in mind:

* A PBS scheduler, which can be OpenPBS or Altair PBS Professional. Support for other scheduler is planned for the future
* It is tailored to run on Azure Milan-X (HBv3-series) and Azure Genoa-X (HBv4-series) CPUs
* It automatically configures appropriate pinning for under-subscribed VMs for Milan-X / Genoa-X architectures
* It assumes the installazion of NVIDIA HPC-X package in `/opt` in each node

## How to install the application

This application can be installed as a standard OnDemand portal application following [the official guide](https://osc.github.io/ood-documentation/latest/install-ihpc-apps.html)

## Required customization

Some customizations will be required in some application files to match system specific configuration. This includes:

* OpenFOAM versions and installation paths
* NVIDIA HPC-X installation path
* The cluster ID to use in Open OnDemand portal

### OpenFOAM versions and installation paths

In order to add the appropriate paths on your HPC system for the OpenFOAM path, the following block needs to be modified `form.yml`:

```
  openfoam_version:
      widget: 'select'
      label: 'OpenFOAM Version'
      value: 'OpenFOAM 11'
      help: |
         OpenFOAM version to be used for simulation
      options:
         - ['OpenFOAM 11', '/shared/apps/OpenFOAM/OpenFOAM-11']
```
Multiple versions can be added:

```
  openfoam_version:
      widget: 'select'
      label: 'OpenFOAM Version'
      value: 'OpenFOAM 11'
      help: |
         OpenFOAM version to be used for simulation
      options:
         - ['OpenFOAM 11', '/shared/apps/OpenFOAM/OpenFOAM-11']
         - ['OpenFOAM 10', '/shared/apps/OpenFOAM/OpenFOAM-10']
```

### NVIDIA HPC-X Installation path

According to standard Azure HPC images, NVIDIA HPC-X stack is installed in `/opt`. If this is not the case, update the relevant portion of `script.sh.erb`.

```
source /etc/profile
source /opt/hpcx*/hpcx-init.sh
hpcx_load
```

### Open OnDemand cluster ID

The following portion of `form.yml` needs to be updated with the relvant cluster ID for Open OnDemand:

```
cluster: ""

```

For example, in the case you have a cluster named `pbs.yml` in  `/etc/ood/config/clusters.d`:

```
cluster: "pbs"

```

