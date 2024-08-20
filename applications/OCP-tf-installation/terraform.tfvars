# Source: https://github.com/ibm-cloud-architecture/terraform-openshift4-vmware

// Connect to bootsrap machine: ssh -i ~/.ssh/id_rsa_ocp core@172.16.85.80
// Credentials: username: kubeadmin, password: ua3vI-nFNHC-Z3VBc-CojSA
// Kubeconfig file of cluster is in installer/auth/kubeconfig

// To shut down environment: https://docs.openshift.com/container-platform/4.13/backup_and_restore/graceful-cluster-shutdown.html

// ID identifying the cluster to create. Use your username so that resources created can be tracked back to you.
cluster_id = "ocp-shlomi-lab-0"

// Base domain from which the cluster domain is a subdomain.
base_domain = "terasky.demo"

// Name of the vSphere server. The dev cluster is on "vcsa.vmware.devcluster.openshift.com".
vsphere_server = "demo-vc-01.terasky.demo"

// User on the vSphere server.
vsphere_user = "tkg-admin@terasky.demo"

// Password of the user on the vSphere server.
vsphere_password = "VMware1!"

// Name of the vSphere cluster. The dev cluster is "devel".
vsphere_cluster = "Demo-Cluster"

// The relative path to the folder which should be used or created for VMs.
# vsphere_folder = "Openshift-lab"
vsphere_folder = "LABS/Shlomi/Openshift-lab/ocp-shlomi-lab-0"

// Name of the vSphere data center. The dev cluster is "dc1".
vsphere_datacenter = "Demo-Datacenter"

// Name of the vSphere data store to use for the VMs. The dev cluster uses "nvme-ds1".
vsphere_datastore = "vsanDatastore"

// If false, creates a resource pool for OpenShift nodes
vsphere_preexisting_resourcepool = true

// The resource pool that should be used or created for VMs
vsphere_resource_pool = "/Demo-Datacenter/host/Demo-Cluster/Resources"

// Name of the RHCOS VM template to clone to create VMs for the cluster
vm_template = "coreos"

// Name of the VM Network for your cluster nodes
vm_network = "shlomi-tkgm-mgmt"

// Name of the VM Network for loadbalancer NIC in loadbalancer.
// loadbalancer_network = "vDPortGroup"

// The machine_cidr where IP addresses will be assigned for cluster nodes. Additionally, IPAM will assign IPs based on the network ID. 
machine_cidr = "172.16.85.0/24"

// The number of control plane VMs to create. Default is 3.
control_plane_count = 3

// The number of compute VMs to create. Default is 3.
compute_count = 3

// Set bootstrap_ip, control_plane_ip, and compute_ip if you want to use static IPs reserved someone else, rather than the IPAM server.

// The IP address to assign to the bootstrap VM.
bootstrap_ip_address = "172.16.85.80"

// The IP addresses to assign to the control plane VMs. The length of this list must match the value of control_plane_count.
control_plane_ip_addresses = ["172.16.85.81", "172.16.85.82", "172.16.85.83"]

// The IP addresses to assign to the compute VMs. The length of this list must match the value of compute_count.
compute_ip_addresses = ["172.16.85.84", "172.16.85.85", "172.16.85.86"]

// The IP addresses of your DNS servers for your OpenShift nodes
vm_dns_addresses = ["10.100.100.100"]

// The IP address of the default gateway.  If not set, it will use the first host of the machine_cidr range.
vm_gateway = "172.16.85.1"

// Path to your OpenShift Pull Secret:
// SHLOMI!!! - CRITCAL - THIS IS THE TOKEN AND IT EXPIRES IN OCTOBER 2024 - YOU CAN RENEW IT IN OPENSHIFT - JUST CREATE NEW USER shlomih+1@terasky - AND GET AN NEW TRIAL - AND GET AGAIN THE PULL SECRET
openshift_pull_secret = "~/openshift/all/pullsecret.txt"

// Set to true (default) so that OpenShift self-hosts its own LoadBalancers (similar to IPI deployments)
// If set to false, you must bring your own LoadBalancers and point the api enpoint to masters and apps endpoint to workers
create_openshift_vips = true

// If create_openshift_vips is set to true, you must provide the IP addresses that will be used for the api and *.apps endpoints
// These IP addresses MUST be on the same CIDR range as machine_cidr
openshift_api_virtualip = "172.16.85.201"
openshift_ingress_virtualip = "172.16.85.200"

// Path to your ssh public key. If left blank we will generate one.
ssh_public_key = "~/.ssh/id_rsa_ocp.pub"

// The number of storage VMs to create. Default is 0.  Set to 0 or 3
// storage_count = 3


// The IP addresses to assign to the storage VMs. The length of this list must
// match the value of storage_count.
//storage_ip_addresses = ["172.16.85.87", "172.16.85.88", "172.16.85.89"]


