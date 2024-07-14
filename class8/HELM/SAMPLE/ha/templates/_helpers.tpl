{{/*
Return the fully qualified app name.
*/}}
{{- define "ha-cluster.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the name of the chart.
*/}}
{{- define "ha-cluster.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Return the labels for the chart.
*/}}
{{- define "ha-cluster.labels" -}}
app.kubernetes.io/name: {{ include "ha-cluster.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}