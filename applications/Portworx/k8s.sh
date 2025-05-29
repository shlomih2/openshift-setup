# Get the internal IPs of worker nodes
IPS=$(oc get nodes --selector=node-role.kubernetes.io/worker -o wide | awk 'NR>1 {print $6}')

# DEVICE=$1
# for IP in $IPS; do
#   echo "Copying fdisk.sh to $IP"
#   scp -i ~/.ssh/id_rsa_ocp fdisk.sh core@$IP:/tmp/fdisk.sh

#   echo "Running fdisk.sh on $IP"
#   ssh -i ~/.ssh/id_rsa_ocp core@$IP "chmod +x /tmp/fdisk.sh && sudo /tmp/fdisk.sh $DEVICE"
# done

kubectl apply -f cluster-monitoring-config.yaml

kubectl create namespace portworx

kubectl apply -f px_oper.yaml -n portworx
kubectl apply -f stc.yaml -n portworx
kubectl apply -f sc.yaml -n portworx