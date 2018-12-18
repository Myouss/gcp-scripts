# SAP Hana Installation
Hana will be setup using the standard scripts and templates provided by GCP.

## Prerequisites
In order to be able to run the scripts present in this repository it is necessary to have Google Cloud SDK installed on the developers' workstation.

### Service Accounts
In a Shared VPC environment the service account that will run the Deployment Manager (by default `{project_number}@cloudservices.gserviceaccount.com`), needs to have `Compute Admin` in the service project and `Compute Network Admin` on in the host project.

Additionally, also the service account that will run on the VMs (by default `{project_number}-compute@developer.gserviceaccount.com`) needs to be given  and `Compute Instance Admin` in the service project and `Compute Network User` in the host project.

## Setup
First update the file `setup.sh`. 
In `setup.sh`, the variables at the beginning of the file need to be updated with the values of the current environment.
```bash
PROJECT=""
INSTANCE_NAME=""
NETWORK_NAME=""
SUBNET=""
ZONE=""
TAG=""
```

### Networking
Depending on the networking configuration, the VMs might need to be tagged with specific labels. This can be done by updating the configuration parameter `networkTag` in `config.yaml`. More details for the setup can be found under [https://cloud.google.com/solutions/partners/sap/sap-hana-deployment-guide](https://cloud.google.com/solutions/partners/sap/sap-hana-deployment-guide).

## Running
Once the file is updated, it can be run, by executing:
```bash
$ ./setup.sh
```

## How does it work?
The script `setup.sh` executes the Deployment Manager (DM) template `sap_hana_deployment.py`. This template will prepare and then deploy the template `sap_hana.py`. The official version of this template can be found under [https://storage.googleapis.com/sapdeploy/dm-templates/sap_hana/sap_hana.py](https://storage.googleapis.com/sapdeploy/dm-templates/sap_hana/sap_hana.py).
`sap_hana_deployment.py` accepts the same parameters are `sap_hana.py` but additionally it sets up the service account and assigns it the right permissions.
However, for customization purposes the same files can be found in the directory `dm-templates`.
The template `templates/sap_hana/sap-hana.py` creates the necessary infrastructure for hosting Hana and then executes the scripts `dm-templates/sap_hana/startup.sh` on the master node and `dm-templates/sap_hana/startup_secondary.sh` on the worker nodes. The startup scripts in turn will call functions defined in `dm-templates/lib/sap_lib_main.sh` and `dm-templates/lib/sap_lib_hdb.sh`, that will perform the actual installation on the VMs.

# SAP Operations

## Prerequisites
The following steps must be performed before starting the scripts performing changes on the infrastructure.

### Python

The scripts for the operations are running using python 3.6 and using the Google Client APIs.
In order to setup such an environment it is necessary to install python 3.6 first and then installing the necessary dependencies.

The python dependencies can be installed by running:
```bash
$ pip3 install --upgrade google-api-python-client
```

More information can be found [here](https://developers.google.com/api-client-library/python/start/installation).

### Service Account

The script will be run as a service account. It is hence necessary to:

* setup a service account.
* download the respective credentials in JSON format.
* export the location of the credentials so that they are usable from the script.
  ```bash
  $ export GOOGLE_APPLICATION_CREDENTIALS=full_path_of_service_account_credentials
  ```

## Reprovisioning
### Setup
The variables in the file `reprovision.py` need to be updated with the information relevant for your environment.
```python
project = ""
region = ""
zone = ""
original_vm_name = ""
new_MachineType = ""
```
### Running
To run the scale up it is necessary to run the following command. 
```bash
$ reprovision.py
```
### How does it work?
The script copies the current configuration of a VM and creates a new VM with the same configuration. The reason of performing such an operations instead of changing directly the VM size, is to allow to perform extra additional checks and possible steps before the VMs comes up to life, e.g. check the processor architecture, add NICs etc.

## Scale out
### Setup
The variables in the file `scale_out.py` need to be updated with the information relevant for your environment.
```python
project = ""
network_name = ""
subnet = ""
region = ""
zone = ""
sys_nr = ""
passwd = ""
instance_name = ""
worker = instance_name + 'w1' # the suffix is the name of the node that will be copied
new_worker = instance_name + 'w2' # the suffix is the name of the new node that will be added
```

In addition to that, also the script for the opeartions `hana_operations.sh`, need to be updated
```bash
PROJECT=""
NETWORK_NAME=""
SUBNET=""
ZONE=""
TAG=""
SID=""
VM_NAME=""
SYS_NR=""
PASSWD=""
NEW_INSTANCE_NUMBER="" # this will be the number of the new VM, assuming the vm will terminate with w${NEW_INSTANCE_NUMBER}
```

### Running
To run the scale up it is necessary to run the following command. 
```
$ scale_out.py
```
### How does it work?
The operations are separated for the infrastructure and the system point of view.
The infrastructure opeartions are performed using python and the [Google API Client Library](https://developers.google.com/api-client-library/python/), the script containing the infrastructure opeartions is `scale_out.py`. The infrastructure script will call the system opeartions.
The system opeartions are stored in `hana_opeartions.py`.

When launching the opeartion under the hood the following will happen:

1. The database will be stopped.
1. A new worker will be created from a copy of the worker 1.
1. The new worker will be connected to the existing cluster.