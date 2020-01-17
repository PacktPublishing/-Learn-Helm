{{- define "guestbook-basic.common-labels" -}}
"app.kubernetes.io/name": {{ .Chart.Name }}
"helm.sh/chart": {{ .Chart.Name }}-{{ .Chart.Version }}
"app.kubernetes.io/managed-by": {{ .Release.Service }}
"app.kubernetes.io/instance": {{ .Release.Name }}
{{- end -}}