{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kube-state-metrics.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kube-state-metrics.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "kube-state-metrics.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "kube-state-metrics.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "kube-state-metrics.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-state-metrics.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate basic labels
*/}}
{{- define "kube-state-metrics.labels" }}
helm.sh/chart: {{ template "kube-state-metrics.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: metrics
app.kubernetes.io/part-of: {{ template "kube-state-metrics.name" . }}
{{- include "kube-state-metrics.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- with (mergeOverwrite (deepCopy .Values.global.podLabels) .Values.customLabels) }}
{{ toYaml . }}
{{- end }}
{{- if .Values.releaseLabel }}
release: {{ .Release.Name }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kube-state-metrics.selectorLabels" }}
{{- if .Values.selectorOverride }}
{{ toYaml .Values.selectorOverride }}
{{- else }}
app.kubernetes.io/name: {{ include "kube-state-metrics.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- end }}

{{/* Sets default scrape limits for servicemonitor */}}
{{- define "servicemonitor.scrapeLimits" -}}
{{- with .sampleLimit }}
sampleLimit: {{ . }}
{{- end }}
{{- with .targetLimit }}
targetLimit: {{ . }}
{{- end }}
{{- with .labelLimit }}
labelLimit: {{ . }}
{{- end }}
{{- with .labelNameLengthLimit }}
labelNameLengthLimit: {{ . }}
{{- end }}
{{- with .labelValueLengthLimit }}
labelValueLengthLimit: {{ . }}
{{- end }}
{{- end -}}

{{/*
The image to use for kube-state-metrics
*/}}
{{- define "kube-state-metrics.image" -}}
{{- if .Values.image.sha }}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s@%s" .Values.global.imageRegistry .Values.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.image.tag) .Values.image.sha }}
{{- else }}
{{- printf "%s/%s:%s@%s" .Values.image.registry .Values.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.image.tag) .Values.image.sha }}
{{- end }}
{{- else }}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.image.tag) }}
{{- else if and (contains "." .Values.image.repository) (contains "/" .Values.image.repository) }}
{{- printf "%s:%s" .Values.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.image.tag) }}
{{- else }}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.image.tag) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
The image to use for kubeRBACProxy
*/}}
{{- define "kubeRBACProxy.image" -}}
{{- if .Values.kubeRBACProxy.image.sha }}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s@%s" .Values.global.imageRegistry .Values.kubeRBACProxy.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.kubeRBACProxy.image.tag) .Values.kubeRBACProxy.image.sha }}
{{- else }}
{{- printf "%s/%s:%s@%s" .Values.kubeRBACProxy.image.registry .Values.kubeRBACProxy.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.kubeRBACProxy.image.tag) .Values.kubeRBACProxy.image.sha }}
{{- end }}
{{- else }}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.kubeRBACProxy.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.kubeRBACProxy.image.tag) }}
{{- else }}
{{- printf "%s/%s:%s" .Values.kubeRBACProxy.image.registry .Values.kubeRBACProxy.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.kubeRBACProxy.image.tag) }}
{{- end }}
{{- end }}
{{- end }}

{{- define "kube-state-metrics.securityContext" }}
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

{{- define "kube-state-metrics.containerSecurityContext" }}
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