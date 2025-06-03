{{- define "pod.content" -}}
      {{- if .Values.global.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ .Values.global.terminationGracePeriodSeconds }}
      {{- end }}
      {{- include "common.pullSecrets" $ | nindent 6 }}
      {{- if .Values.global.nodeSelector }}
      nodeSelector: {{- tpl ( .Values.global.nodeSelector | toYaml ) $ | nindent 8 }}
      {{- end }}
      {{- if .Values.global.tolerations }}
      tolerations: {{- tpl ( .Values.global.tolerations | toYaml ) $ | nindent 8 }}
      {{- end }}
      {{- if .Values.global.podSecurityContext.enabled }}
      securityContext: {{- omit .Values.global.podSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ include "common.name" $ }}
          image: {{ include "common.image" $ }}
          imagePullPolicy: {{ .Values.global.image.pullPolicy | quote }}
          {{- if .Values.global.containerSecurityContext.enabled }}
          securityContext: {{- omit .Values.global.containerSecurityContext "enabled" | toYaml | nindent 12 }}
          {{- end }}
          {{- if .Values.global.command }}
          command: {{- tpl ( .Values.global.command | toYaml ) $ | nindent 12 }}
          {{- end }}
          {{- if .Values.global.args }}
          args: {{- tpl ( .Values.global.args | toYaml ) $ | nindent 12 }}
          {{- end }}
          {{- if .Values.global.lifecycleHooks }}
          lifecycle: {{- tpl ( .Values.global.lifecycleHooks | toYaml ) $ | nindent 12 }}
          {{- end }}
          {{- if or .Values.global.extraEnvVars .Values.envVars }}
          {{- $envVars := list }}
          {{- $envVars = concat $envVars ( include "common.tpl" ( dict "Template" .Values.envVars "Root" $ ) | fromYamlArray ) }}
          {{- $envVars = concat $envVars ( include "common.tpl" ( dict "Template" .Values.global.extraEnvVars "Root" $ ) | fromYamlArray ) }}
          env:
            {{- $envVars | toYaml | nindent 12 }}
          {{- end }}
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
            {{- include "common.tpl.ports" ( dict "Root" . "Template" $containerPorts ) | nindent 12 }}
          {{- end }}

          {{- if .Values.global.livenessProbe }}
          livenessProbe: {{- include "common.tpl" (dict "Template" .Values.global.livenessProbe "Root" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.global.readinessProbe }}
          readinessProbe: {{- include "common.tpl" (dict "Template" .Values.global.readinessProbe "Root" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.global.startupProbe }}
          startupProbe: {{- include "common.tpl" (dict "Template" .Values.global.startupProbe "Root" $) | nindent 12 }}
          {{- end }}

          {{- if .Values.global.resources }}
          resources: {{- toYaml .Values.global.resources | nindent 12 }}
          {{- end }}
          {{- if or .Values.volumeMounts .Values.global.extraVolumeMounts }}
            {{- $volumeMounts := concat (list) .Values.volumeMounts .Values.global.extraVolumeMounts }}
          volumeMounts:
            {{- include "common.volumesMounts" ( dict "VolumeMounts" $volumeMounts "Root" $ ) }}
          {{- end }}
      {{- $containers := concat (list) .Values.containers .Values.global.extraContainers }}
      {{- if $containers }}
      {{- tpl ( $containers | toYaml ) $ | nindent 8 }}
      {{- end }}
      {{- $initContainers := concat (list) .Values.initContainers .Values.global.extraInitContainers }}
      {{- if $initContainers }}
      initContainers:
      {{- tpl ( $initContainers | toYaml ) $ | nindent 8 }}
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
