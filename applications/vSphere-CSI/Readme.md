# Install CSI on Openshift - VMware

Configure the vSphere CSI Driver in environments OpenShift 4.x without the need to use the operator that VMWare already developed

## Source:
* https://24xsiempre.com/en/como-instalar-vsphere-csi-driver-en-redhat-openshift-4-x/

## Steps:

1. Create csi-vsphere.conf and vsphere.conf files both containing:
```conf
[Global]
cluster-id = "f7ac2418-c0f2-4599-9950-fe7fdf9306db"

[VirtualCenter "demo-vc-01.terasky.demo"]
insecure-flag = "true"
user = "tkg-admin@terasky.demo"
password = "VMware1!"
datacenters = "Demo-Datacenter"
port = "443"
```

2. Create a secret and a configmap
```bash
oc create secret generic vsphere-config-secret --from-file=csi-vsphere.conf --namespace=kube-system
oc create configmap cloud-config --from-file=vsphere.conf --namespace=kube-system
```

3. Taint nodes
```bash
kubectl taint nodes --all 'node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule'
```

4. Apply yamls
```bash
oc apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
oc apply -f https://github.com/kubernetes/cloud-provider-vsphere/raw/master/manifests/controller-manager/vsphere-cloud-controller-manager-ds.yaml
```

5. Install vsphere csi 
```bash
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/v2.1.1/manifests/v2.1.1/vsphere-7.0u1/vanilla/rbac/vsphere-csi-controller-rbac.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/v2.1.1/manifests/v2.1.1/vsphere-7.0u1/vanilla/deploy/vsphere-csi-node-ds.yaml
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/v2.1.1/manifests/v2.1.1/vsphere-7.0u1/vanilla/deploy/vsphere-csi-controller-deployment.yaml
```

6. Create storageclass

* First create a VM Storage Policies

* Then get the datastore's url

* Create storageclass 

```bash
cat << EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: sc-csi-vsphere
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi.vsphere.vmware.com
parameters:
  StoragePolicyName: "ocp-shlomi"
  datastoreURL: "ds:///vmfs/volumes/vsan:52de39076e99c733-3a9ee62808d57b6a/"
EOF
```