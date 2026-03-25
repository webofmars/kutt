{{/*
Expand the name of the chart.
*/}}
{{- define "kutt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kutt.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kutt.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kutt.labels" -}}
helm.sh/chart: {{ include "kutt.chart" . }}
{{ include "kutt.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kutt.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kutt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kutt.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kutt.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Determine the database client to use.
Precedence: explicit kutt.db.client > postgresql.enabled > mariadb.enabled > sqlite (default)
*/}}
{{- define "kutt.dbClient" -}}
{{- if .Values.postgresql.enabled }}
{{- "pg" }}
{{- else if .Values.mariadb.enabled }}
{{- "mysql2" }}
{{- else }}
{{- .Values.kutt.db.client | default "better-sqlite3" }}
{{- end }}
{{- end }}

{{/*
Determine the database host.
*/}}
{{- define "kutt.dbHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else if .Values.mariadb.enabled }}
{{- printf "%s-mariadb" .Release.Name }}
{{- else }}
{{- .Values.kutt.db.host | default "" }}
{{- end }}
{{- end }}

{{/*
Determine the database port.
*/}}
{{- define "kutt.dbPort" -}}
{{- if .Values.postgresql.enabled }}
{{- "5432" }}
{{- else if .Values.mariadb.enabled }}
{{- "3306" }}
{{- else }}
{{- .Values.kutt.db.port | default "" }}
{{- end }}
{{- end }}

{{/*
Determine the database name.
*/}}
{{- define "kutt.dbName" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | default "kutt" }}
{{- else if .Values.mariadb.enabled }}
{{- .Values.mariadb.auth.database | default "kutt" }}
{{- else }}
{{- .Values.kutt.db.name | default "kutt" }}
{{- end }}
{{- end }}

{{/*
Determine the database user.
*/}}
{{- define "kutt.dbUser" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | default "kutt" }}
{{- else if .Values.mariadb.enabled }}
{{- .Values.mariadb.auth.username | default "kutt" }}
{{- else }}
{{- .Values.kutt.db.user | default "" }}
{{- end }}
{{- end }}

{{/*
Name of the secret holding the DB password.
When using sub-charts, each sub-chart creates its own secret; reference it here.
Otherwise fall back to the kutt managed secret.
*/}}
{{- define "kutt.dbSecretName" -}}
{{- if .Values.kutt.db.existingSecret }}
{{- .Values.kutt.db.existingSecret }}
{{- else if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else if .Values.mariadb.enabled }}
{{- printf "%s-mariadb" .Release.Name }}
{{- else }}
{{- include "kutt.fullname" . }}
{{- end }}
{{- end }}

{{/*
Key of the DB password in the secret.
*/}}
{{- define "kutt.dbSecretKey" -}}
{{- if .Values.postgresql.enabled }}
{{- "password" }}
{{- else if .Values.mariadb.enabled }}
{{- "mariadb-password" }}
{{- else }}
{{- "DB_PASSWORD" }}
{{- end }}
{{- end }}

{{/*
Determine whether Redis is enabled (sub-chart or explicit).
*/}}
{{- define "kutt.redisEnabled" -}}
{{- if or .Values.redis.enabled .Values.kutt.redis.enabled }}
{{- "true" }}
{{- else }}
{{- "false" }}
{{- end }}
{{- end }}

{{/*
Determine the Redis host.
*/}}
{{- define "kutt.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" .Release.Name }}
{{- else }}
{{- .Values.kutt.redis.host | default "127.0.0.1" }}
{{- end }}
{{- end }}

{{/*
Name of the secret holding the Redis password.
*/}}
{{- define "kutt.redisSecretName" -}}
{{- if .Values.kutt.redis.existingSecret }}
{{- .Values.kutt.redis.existingSecret }}
{{- else if .Values.redis.enabled }}
{{- printf "%s-redis" .Release.Name }}
{{- else }}
{{- include "kutt.fullname" . }}
{{- end }}
{{- end }}

{{/*
Key of the Redis password in the secret.
*/}}
{{- define "kutt.redisSecretKey" -}}
{{- if .Values.redis.enabled }}
{{- "redis-password" }}
{{- else }}
{{- "REDIS_PASSWORD" }}
{{- end }}
{{- end }}

{{/*
Name of the secret holding the JWT secret.
*/}}
{{- define "kutt.jwtSecretName" -}}
{{- if .Values.kutt.auth.existingSecret }}
{{- .Values.kutt.auth.existingSecret }}
{{- else }}
{{- include "kutt.fullname" . }}
{{- end }}
{{- end }}

{{/*
Name of the secret holding the Mail password.
*/}}
{{- define "kutt.mailSecretName" -}}
{{- if .Values.kutt.mail.existingSecret }}
{{- .Values.kutt.mail.existingSecret }}
{{- else }}
{{- include "kutt.fullname" . }}
{{- end }}
{{- end }}

{{/*
Name of the secret holding the OIDC client secret.
*/}}
{{- define "kutt.oidcSecretName" -}}
{{- if .Values.kutt.oidc.existingSecret }}
{{- .Values.kutt.oidc.existingSecret }}
{{- else }}
{{- include "kutt.fullname" . }}
{{- end }}
{{- end }}
