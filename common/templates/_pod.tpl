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
          {{- if or .Values.containerPorts .Values.global.extraContainerPorts }}
          {{- $containerPorts := concat (list) .Values.containerPorts .Values.global.extraContainerPorts }}
          ports:
            {{- tpl ( $containerPorts | toYaml ) $ | nindent 12 }}
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

{{- end -}}
