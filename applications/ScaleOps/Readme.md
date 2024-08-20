# Installation

```sh
helm repo add scaleops --username scaleops --password a%h%p_CT%vzn%e5H%WpGc%cl7pXWOFDIQC0TKDVg4RmcPD \
https://raw.githubusercontent.com/scaleops-sh/helm-charts/main/

helm repo update scaleops

helm upgrade --install --create-namespace -n scaleops-system \
  --repo https://raw.githubusercontent.com/scaleops-sh/helm-charts/main/ \
  --username scaleops --password a%h%p_CT%vzn%e5H%WpGc%cl7pXWOFDIQC0TKDVg4RmcPD \
  --set scaleopsToken=a%h%p_CT%vzn%e5H%WpGc%cl7pXWOFDIQC0TKDVg4RmcPD \
  --set clusterName=terasky-$(oc config current-context) \
  --set global.openShift=true \
  --set dashboard.serviceType=ClusterIP \
  scaleops scaleops

oc adm policy add-scc-to-user privileged -z scaleops-prometheus-server -n scaleops-system

```

note: remove % from key later