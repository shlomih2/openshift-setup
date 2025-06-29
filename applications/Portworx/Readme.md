* Run `px-ocp.sh <device file for portworx>` to install portworx on openshift as bare metal deployment
* Example `px-ocp.sh /dev/nvme0n1`

## Files Description

### cluster-monitoring-config.yaml
- Configures cluster monitoring settings for OpenShift
- Enables monitoring capabilities for the cluster

### px_oper.yaml
- Defines the Portworx operator deployment
- Creates necessary RBAC (Role-Based Access Control) resources:
  - ServiceAccount: portworx-operator
  - ClusterRole: portworx-operator
  - ClusterRoleBinding: portworx-operator
- Deploys the Portworx operator using image: portworx/px-operator:25.2.0

### stc.yaml (StorageCluster)
- Defines the Portworx storage cluster configuration
- Key configurations:
  - Uses internal KVDB
  - Storage devices: /dev/nvme0n2
  - System metadata device: /dev/nvme0n1
  - Enables STORK for storage orchestration
  - Enables CSI (Container Storage Interface)
  - Enables monitoring and telemetry
  - Uses portworx/oci-monitor:3.2.3 image

### sc.yaml (StorageClass)
- Defines the Portworx storage class configuration
- Named: px-csi-no-repl
- Key parameters:
  - fastpath: enabled
  - nodiscard: enabled
  - priority_io: high
  - replication: 1
  - secure: false
  - block_size: 131072 (128 KiB)
  - queue_depth: 256
- Mount options:
  - noatime
  - nodiratime
  - nobarrier
- Uses pxd.portworx.com as provisioner
- Allows volume expansion
