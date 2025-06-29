oc -n portworx apply -f https://docs.portworx.com/samples/portworx-enterprise/k8s/pxc/grafana-service-account.yaml 
oc -n portworx adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana
oc -n portworx create token grafana --duration=8760h
oc -n portworx create configmap grafana-dashboard-config --from-file=conf_files/monitoring/grafana-dashboard-config.yaml
oc -n portworx create configmap grafana-source-config --from-file=conf_files/monitoring/grafana-datasource-ocp.yaml
# curl "https://docs.portworx.com/samples/portworx-enterprise/k8s/pxc/portworx-cluster-dashboard.json" -o portworx-cluster-dashboard.json && \
# curl "https://docs.portworx.com/samples/portworx-enterprise/k8s/pxc/portworx-node-dashboard.json" -o portworx-node-dashboard.json && \
# curl "https://docs.portworx.com/samples/portworx-enterprise/k8s/pxc/portworx-volume-dashboard.json" -o portworx-volume-dashboard.json && \
# curl "https://docs.portworx.com/samples/portworx-enterprise/k8s/pxc/portworx-performance-dashboard.json" -o portworx-performance-dashboard.json && \
# curl "https://docs.portworx.com/samples/portworx-enterprise/k8s/pxc/portworx-etcd-dashboard.json" -o portworx-etcd-dashboard.json
oc -n portworx create configmap grafana-dashboards \
--from-file=conf_files/monitoring/portworx-cluster-dashboard.json \
--from-file=conf_files/monitoring/portworx-performance-dashboard.json \
--from-file=conf_files/monitoring/portworx-node-dashboard.json \
--from-file=conf_files/monitoring/portworx-volume-dashboard.json \
--from-file=portworx-etcd-dashboard.json 
oc -n portworx apply -f https://docs.portworx.com/samples/portworx-enterprise/k8s/pxc/grafana-ocp.yaml
oc expose service grafana