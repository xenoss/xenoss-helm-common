{{/*
Looks if there's an existing secret and reuse its password. If not it generates
new password and use it.
*/}}
{{- define "common.password" -}}
{{- $secret := (lookup "v1" "Secret" .Namespace .SecretName ) }}
{{- if $secret }}
{{- index $secret "data" .PasswordKey }}
{{- else }}
{{- (randAlphaNum 40) | b64enc | quote }}
{{- end }}
{{- end }}
