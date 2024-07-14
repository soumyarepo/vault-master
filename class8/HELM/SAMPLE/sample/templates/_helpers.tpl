{{/*
Return the fully qualified app name.
*/}}
{{- define "simplechart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the name of the chart.
*/}}
{{- define "simplechart.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Return the labels for the chart.
*/}}
{{- define "simplechart.labels" -}}
app.kubernetes.io/name: {{ include "simplechart.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}