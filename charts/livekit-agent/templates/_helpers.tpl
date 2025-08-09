{{- define "livekit-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 -}}
{{- end -}}

{{- define "livekit-agent.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 -}}
{{- end -}}

{{- define "livekit-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{- if .Values.serviceAccount.name -}}
    {{- .Values.serviceAccount.name -}}
  {{- else -}}
    {{- include "livekit-agent.fullname" . }}-sa
  {{- end -}}
{{- else -}}
  default
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "livekit-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Common labels
*/}}
{{- define "livekit-agent.labels" -}}
helm.sh/chart: {{ include "livekit-agent.chart" . }}
{{ include "livekit-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "livekit-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "livekit-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}