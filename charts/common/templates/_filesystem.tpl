{{- define "filesystem.configuration" -}}
  {{- $conf := merge (dict) .Values.global.storage.configuration -}}
  {{- if hasKey .Values.global.storage "configurationFrom" }}
    {{- range .Values.global.storage.configurationFrom.secret.properties }}
      {{- $conf = merge (dict) $conf (dict .target ( printf "${env.%s}" .env ) ) }}
    {{- end -}}
  {{- end -}}
  json({{ $conf | toJson }})
{{- end -}}

{{- define "filesystem.env" -}}
  {{- if hasKey .Values.global.storage "configurationFrom" }}
    {{- range .Values.global.storage.configurationFrom.secret.properties }}
- name: {{ .env | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.global.storage.configurationFrom.secret.name  | quote }}
      key: {{ .source | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}
