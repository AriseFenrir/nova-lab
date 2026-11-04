{{/* Nom complet : évite "nova-hello-nova-hello" si la release porte déjà le nom du chart */}}
{{- define "nova-hello.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Labels de sélection : IMMUABLES après la 1re installation */}}
{{- define "nova-hello.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Labels communs (métadonnées) */}}
{{- define "nova-hello.labels" -}}
{{ include "nova-hello.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.app.version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
nova/environment: {{ .Values.app.environment | quote }}
{{- end -}}

{{/* Nom du Secret réellement utilisé */}}
{{- define "nova-hello.secretName" -}}
{{- if .Values.secret.existingSecret -}}
{{- .Values.secret.existingSecret -}}
{{- else -}}
{{- printf "%s-secret" (include "nova-hello.fullname" .) -}}
{{- end -}}
{{- end -}}
