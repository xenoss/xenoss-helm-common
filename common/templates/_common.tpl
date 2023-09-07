{{- define "common.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.global.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "common.fullname.service" -}}
{{- include "common.fullname" . }}{{ if eq $.Values.global.service.clusterIP "None" }}-headless{{ end }}
{{- end -}}

{{- define "common.namespace" -}}
{{- default .Release.Namespace .Values.global.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
helm.sh/chart: {{ include "common.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "common.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "common.image" -}}
{{- $registryName := .Values.global.image.registry -}}
{{- $repositoryName := .Values.global.image.repository -}}
{{- $separator := ":" -}}
{{- $termination := .Values.global.image.tag | toString -}}
{{- if .Values.global.image.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .Values.global.image.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{- define "common.pullSecrets" -}}
  {{- $pullSecrets := list }}

{{- range .Values.imagePullSecrets -}}
  {{- $pullSecrets = append $pullSecrets . -}}
{{- end -}}
{{- range .Values.global.imagePullSecrets -}}
  {{- $pullSecrets = append $pullSecrets . -}}
{{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}


{{- define "common.podAnnotations" -}}
      {{- if or .Values.podAnnotations .Values.global.podAnnotations .Values.configMaps .Values.global.configMaps }}
      {{- $podAnnotations := merge (dict) .Values.podAnnotations .Values.global.podAnnotations }}
      {{- $configMaps := merge (dict) .Values.configMaps .Values.global.configMaps }}
      annotations:
        {{- if $configMaps }}
          {{- range $key,$conf := $configMaps }}
            {{- range $file,$con := $conf.files }}
        checksum/{{ $file }}: {{ tpl $con $ | sha256sum }}
            {{- end }}
          {{- end }}
        {{- end }}
        {{- if $podAnnotations }}
        {{- tpl ( $podAnnotations | toYaml ) $ | nindent 8 }}
        {{- end }}
      {{- end }}
{{- end -}}

{{- define "common.volumesMounts" -}}
  {{- $volumeMounts := .VolumeMounts }}
  {{- range $volumeMount := $volumeMounts }}
    {{- $_ := set $volumeMount "name" ( regexReplaceAll "\\W+" ( tpl $volumeMount.name $.Root ) "-" )  }}
  {{- end }}
{{- tpl ( $volumeMounts | toYaml ) $.Root | nindent 12 }}
{{- end -}}

{{- define "commmon.replicaCount" -}}
  {{- if .Values.global.statefulset.enabled -}}
     {{- .Values.global.statefulset.replicaCount -}}
  {{- else if .Values.global.deployment.enabled -}}
     {{- .Values.global.deployment.replicaCount -}}
  {{- else -}}
     1
  {{- end -}}
{{- end }}