{{- define "xenoss.clickhouse.names.fullname" -}}
  {{- if gt ( .Shards | int ) 1 }}
    {{- printf "%s-shard%d" (include "common.names.fullname" .Root ) .Shard -}}
  {{- else -}}
    {{- include "common.names.fullname" .Root -}}
  {{- end -}}
{{- end -}}
