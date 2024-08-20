
{{- define "scaleops.apiserver-endpoints-ip-blocks" }}
{{- if .Values.global.networkPolicy.apiServerEndpointsCIDRs }}
{{- range .Values.global.networkPolicy.apiServerEndpointsCIDRs }}
        - ipBlock:
            cidr: {{ . }}
{{- end }}
{{- else }}
{{- $endpoint := (lookup "v1" "Endpoints" "default" "kubernetes") }}
{{- $ips := $endpoint.subsets }}
{{- range $ips }}
{{- range .addresses }}
        - ipBlock:
            cidr: {{ .ip }}/32
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "scaleops.ingress-apiserver" }}
    - from:
{{- include "scaleops.apiserver-endpoints-ip-blocks" . }}
      ports:
        - port: 10250
          protocol: TCP
{{- end }}

{{- define "scaleops.egress-apiserver" }}
    - to:
{{- include "scaleops.apiserver-endpoints-ip-blocks" . }}
        - ipBlock:
{{- if .Values.global.networkPolicy.apiServerServiceCIDR }}
            cidr: {{ .Values.global.networkPolicy.apiServerServiceCIDR }}
{{- else }}
{{- $service := (lookup "v1" "Service" "default" "kubernetes") }}
{{- $spec := $service.spec }}
{{- $clusterIP := $spec.clusterIP }}
            cidr: {{ $clusterIP }}/32
{{- end }}
      ports:
        - port: 443
          protocol: TCP
{{- end }}

{{- define "scaleops.egress-dns" }}
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
{{- end }}


{{- define "scaleops.ingress" }}
{{- include "scaleops.ingress-apiserver" . }}
    - from:
        - podSelector:
            matchLabels:
              app: prometheus
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: scaleops-agent
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: scaleops-recommender
      ports:
        - port: 8080
          protocol: TCP
        - port: 18080
          protocol: TCP
{{- end }}

{{- define "scaleops.egress" }}
{{- include "scaleops.egress-apiserver" . }}
{{- include "scaleops.egress-dns" . }}
    - to:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: scaleops-dashboards
      ports:
        - port: 8080
          protocol: TCP
        - port: 18080
          protocol: TCP
    - to:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: repo-updater
      ports:
        - port: 8081
          protocol: TCP
    - to:
        - podSelector:
            matchLabels:
              app: prometheus
      ports:
        - port: 9090
          protocol: TCP
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "scaleops.name" -}}
{{- printf "scaleops-%s" .nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "scaleops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "scaleops.labels" -}}
scaleops.sh: "true"
helm.sh/chart: {{ include "scaleops.chart" . }}
{{ include "scaleops.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "scaleops.selectorLabels" -}}
app.kubernetes.io/name: {{ include "scaleops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the json for the docker registry credentials
*/}}
{{- define "imagePullSecret" -}}
{{- printf "{\"auths\":{\"ghcr.io/scaleops-sh\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" "scaleops" (required ".scaleopsToken must be passed" .Values.scaleopsToken) (printf "%s:%s" "scaleops" .Values.scaleopsToken | b64enc) | b64enc }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "scaleops.fullname" -}}
{{- if .fullnameOverride }}
{{- .fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default $.Chart.Name .nameOverride }}
{{- if contains $name $.Release.Name }}
{{- $.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "scaleops.serviceAccountName" -}}
{{- default "scaleops" .serviceAccount.name }}
{{- end }}

{{/*https://stackoverflow.com/a/72227345*/}}
{{- define "scaleops.multicluster.tagList" -}}
{{- $list := list }}
{{- range .Values.multicluster.tags }}
{{- $list = append $list (printf "\"%s\"" .) }}
{{- end }}
{{- join ", " $list }}
{{- end }}


{{- define "scaleops.syncLevel" -}}
{{- $args := list -}}
{{- if (or (.Values.disableEgress) (.Values.disableSync)) -}}
{{- $args = append $args "--sync-level=1" -}}
{{- else -}}
{{- $args = append $args (printf "--sync-level=%v" .Values.syncLevel) -}}
{{- end -}}
{{ $args | toYaml}}
{{- end }}

{{- define "isOpenShift" -}}
    {{- or (.Values.global.openShift) (.Values.prometheus.openshift) -}}
{{- end -}}

{{/*
    defaultSecurityContextEnabled -> global.securityContext -> securityContext
    omit `enabled` for backward compability
*/}}
{{- define "scaleops.securityContext" -}}
{{- $mergedDict := mergeOverwrite (deepCopy .Values.global.securityContext) .securityContext }}
{{- if .Values.global.defaultSecurityContextEnabled }}
{{- $mergedDict = mergeOverwrite (deepCopy .Values.global.defaultSecurityContext) $mergedDict }}
{{- end }}
{{- $mergedDict = omit $mergedDict "enabled" }}
{{- with $mergedDict }}
securityContext:
{{ . | toYaml | nindent 2}}
{{- end }}
{{- end }}

{{/*
    defaultContainerSecurityContext -> global.containerSecurityContext -> containerSecurityContext
    omit `enabled` for backward compability
*/}}
{{- define "scaleops.containerSecurityContext" -}}
{{- $mergedDict := mergeOverwrite (deepCopy .Values.global.containerSecurityContext) .containerSecurityContext }}
{{- if .Values.global.defaultSecurityContextEnabled -}}
{{- $mergedDict = mergeOverwrite (deepCopy .Values.global.defaultContainerSecurityContext) $mergedDict }}
{{- end }}
{{- $mergedDict = omit $mergedDict "enabled" }}
{{- with $mergedDict }}
securityContext:
{{ . | toYaml | nindent 2 -}}
{{ end }}
{{- end }}

{{- define "scaleops.additionalLabels" }}
{{- $disableIstioInjection := .Values.global.disableIstioInjection }}
{{- if (hasKey .component "disableIstioInjection") }}
{{- $disableIstioInjection = .component.disableIstioInjection }}
{{- end }}
{{- if $disableIstioInjection }}
sidecar.istio.io/inject: "false"
{{- end }}
{{- with (mergeOverwrite (deepCopy .Values.global.podLabels) .component.podLabels) }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "scaleops.additionalAnnotations" }}
{{- with (mergeOverwrite (deepCopy .Values.global.podAnnotations) .component.podAnnotations) }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Useing the secret names from the values, this creates the volumes for the deployment
Secret list in values.yaml:
authConfigSecretName
cloudProviderSecretName
gitSyncSecretName
slackSecretName
*/}}
{{- define "scaleops.secretVolumes" -}}
- name: {{ .Values.authConfigSecretName }}
  secret:
    secretName: {{ .Values.authConfigSecretName }}
    optional: true
- name: {{ .Values.gitSyncSecretName }}
  secret:
    secretName: {{ .Values.gitSyncSecretName }}
    optional: true
- name: {{ .Values.slackSecretName }}
  secret:
    secretName: {{ .Values.slackSecretName }}
    optional: true
- name: {{ .Values.childMultiClusterParentDetailsSecretName }}
  secret:
    secretName: {{ .Values.childMultiClusterParentDetailsSecretName }}
    optional: true
- name: helm-{{ .Release.Revision }}
  secret:
    secretName: sh.helm.release.v1.{{- .Release.Name -}}.v{{ .Release.Revision }}
    optional: true
{{- end }}

{{/*
Using the secrets from scaleops.secretVolumes, this creates the volume mounts for the deployment
Secret names in values.yaml:
authConfigSecretName
cloudProviderSecretName
gitSyncSecretName
slackSecretName
References:
1. https://kubernetes.io/docs/concepts/storage/volumes/#secret
2. https://kubernetes.io/docs/concepts/configuration/secret/#use-case-dotfiles-in-a-secret-volume
*/}}
{{- define "scaleops.secretVolumeMounts" -}}
- name: {{ .Values.authConfigSecretName }}
  mountPath: /var/run/secrets/scaleops.sh/{{- .Values.authConfigSecretName }}
- name: {{ .Values.gitSyncSecretName }}
  mountPath: /var/run/secrets/scaleops.sh/{{- .Values.gitSyncSecretName }}
- name: {{ .Values.slackSecretName }}
  mountPath: /var/run/secrets/scaleops.sh/{{- .Values.slackSecretName }}
- name: {{ .Values.childMultiClusterParentDetailsSecretName }}
  mountPath: /var/run/secrets/scaleops.sh/{{- .Values.childMultiClusterParentDetailsSecretName }}
- name: helm-{{ .Release.Revision }}
  mountPath: /var/run/secrets/scaleops.sh/helm-{{ .Release.Revision }}
{{- end }}


{{ define "scaleops.secretEnvVars" -}}
- name: SCALEOPS_AUTH_CONFIG_SECRET_PATH
  value: /var/run/secrets/scaleops.sh/{{- .Values.authConfigSecretName }}
- name: SCALEOPS_GIT_SYNC_SECRET_PATH
  value: /var/run/secrets/scaleops.sh/{{- .Values.gitSyncSecretName }}
- name: SCALEOPS_SLACK_SECRET_PATH
  value: /var/run/secrets/scaleops.sh/{{- .Values.slackSecretName }}
- name: SCALEOPS_HELM_SECRET_PATH
  value: /var/run/secrets/scaleops.sh/helm-{{ .Release.Revision }}
- name: SCALEOPS_CHILD_MULTI_CLUSTER_PARENT_DETAILS_SECRET_PATH
  value: /var/run/secrets/scaleops.sh/{{- .Values.childMultiClusterParentDetailsSecretName }}
- name: SCALEOPS_AUTH_CONFIG_SECRET_NAME
  value: {{ .Values.authConfigSecretName }}
- name: SCALEOPS_GIT_SYNC_SECRET_NAME
  value: {{ .Values.gitSyncSecretName }}
- name: SCALEOPS_SLACK_SECRET_NAME
  value: {{ .Values.slackSecretName }}
- name: SCALEOPS_CHILD_MULTI_CLUSTER_PARENT_DETAILS_SECRET_NAME
  value: {{ .Values.childMultiClusterParentDetailsSecretName }}
{{- end }}

{{- define "authProvider" -}}
{{- $authProvider := .Values.authProvider.provider }}
{{- if eq $authProvider "" -}}
  {{- $authProvider = "none" }}
  {{- if .Values.authProvider.oauth2 }}
    {{- $authProvider = "oauth2" -}}
  {{- else if .Values.authProvider.google }}
    {{- $authProvider = "google" -}}
  {{- else if .Values.authProvider.github }}
    {{- $authProvider = "github" -}}
  {{- else if .Values.authProvider.openshift }}
    {{- $authProvider = "openshift" -}}
  {{- else if or (eq .Values.authProvider.builtInAuth.enabled true) (eq .Values.authProvider.simpleAuth.enabled true) }}
    {{- $authProvider = "simpleAuth" -}}
  {{- end }}
{{- end -}}
{{- if eq $authProvider "builtInAuth" -}}
  {{- $authProvider = "simpleAuth" -}}
{{- else if or (eq $authProvider "okta") (eq $authProvider "azure") -}}
  {{- $authProvider = "oauth2" -}}
{{- end -}}
{{ $authProvider }}
{{- end }}
