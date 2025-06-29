# Get storage and metadata device from parameters
STORAGE_DEVICE="$1"
METADATA_DEVICE="$2"

# Replace devices in stc.yaml
sed -i "s|^\([[:space:]]*-[[:space:]]*\)/dev/.*|\1${STORAGE_DEVICE}|" stc.yaml
sed -i "s|^\([[:space:]]*systemMetadataDevice:[[:space:]]*\)/dev/.*|\1${METADATA_DEVICE}|" stc.yaml

kubectl apply -f cluster-monitoring-config.yaml

kubectl create namespace portworx

kubectl apply -f px_oper.yaml -n portworx
while true; do
  kubectl wait --for=condition=Established --timeout=60s crd/storageclusters.core.libopenstorage.org && break
  echo "Waiting for CRD storageclusters.core.libopenstorage.org to be established... retrying in 5 seconds."
  sleep 5
done
kubectl apply -f stc.yaml -n portworx
kubectl apply -f sc.yaml -n portworx
