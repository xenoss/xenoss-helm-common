{{- define "pod.content" -}}
          {{- if or .Values.envVarsSecret .Values.global.extraEnvVarsSecret .Values.envVarsCM .Values.global.extraEnvVarsCM }}
            {{- $envVarsSecret := concat (list) .Values.envVarsSecret .Values.global.extraEnvVarsSecret }}
            {{- $envVarsCM := concat (list) .Values.envVarsCM .Values.global.extraEnvVarsCM }}
          envFrom:
            {{- range $envVarsCM }}
            - configMapRef:
                name: {{ tpl . $ }}
            {{- end }}
            {{- range $envVarsSecret }}
            - secretRef:
                name: {{ tpl . $ }}
            {{- end }}
          {{- end }}
          {{- if .Values.global.extraContainerPorts }}
          ports:
            {{- tpl ( .Values.global.extraContainerPorts | toYaml ) $ | nindent 12 }}
          {{- end }}

          {{- if .Values.global.resources }}
          resources: {{- toYaml .Values.global.resources | nindent 12 }}
          {{- end }}
          {{- if or .Values.volumeMounts .Values.global.extraVolumeMounts }}
            {{- $volumeMounts := concat (list) .Values.volumeMounts .Values.global.extraVolumeMounts }}
          volumeMounts:
            {{- include "common.volumesMounts" ( dict "VolumeMounts" $volumeMounts "Root" $ ) }}
          {{- end }}
      {{- if or .Values.volumes .Values.global.extraVolumes }}
        {{- $volumes := concat (list) .Values.volumes .Values.global.extraVolumes }}
      volumes:
        {{- range $volume := $volumes }}
          {{- /*    a lowercase RFC 1123 label must consist of lower case alphanumeric characters or '-',*/}}
          {{- /*    and must start and end with an alphanumeric character (e.g.*/}}
          {{- /*    'my-name',  or '123-abc', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?')*/}}
          {{- $_ := set $volume "name" ( regexReplaceAll "\\W+" ( tpl $volume.name $ ) "-" )  }}
        {{- end }}
        {{- tpl ( $volumes | toYaml ) $ | nindent 8 }}
      {{- end }}

  {{- if $.Values.global.persistence.enabled }}
  volumeClaimTemplates:
    - metadata:
        name: data
        labels: {{- include "common.labels" $ | nindent 10 }}
    {{- if or .Values.global.persistence.annotations .Values.commonAnnotations .Values.global.commonAnnotations }}
      {{ $annotations := merge (dict) .Values.global.persistence.annotations .Values.commonAnnotations .Values.global.commonAnnotations }}
        annotations:
       {{- tpl ( $annotations | toYaml ) $ | nindent 10 }}
    {{- end }}
      spec:
        accessModes:
        {{- range $.Values.global.persistence.accessModes }}
          - {{ . | quote }}
        {{- end }}
        resources:
          requests:
            storage: {{ $.Values.global.persistence.size | quote }}
        {{- if $.Values.global.persistence.volumeMode }}
        volumeMode: {{ $.Values.global.persistence.volumeMode }}
        {{- end }}
        {{- if $.Values.global.persistence.selector }}
        selector: {{- tpl $.Values.global.persistence.selector $ | toYaml | nindent 10 }}
        {{- end }}
  {{- end }}
{{- end -}}
