{{- define "practice-web.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "practice-web.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "practice-web.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "practice-web.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{ include "practice-web.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "practice-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "practice-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
