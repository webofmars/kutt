# kutt

A Helm chart for [Kutt](https://kutt.it) – a free, modern URL shortener.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10+
- PV provisioner support in the cluster (for SQLite persistence)

## Installing the Chart

Add the repository and install the chart:

```bash
helm install my-kutt ./helm/kutt \
  --set kutt.auth.jwtSecret=$(openssl rand -hex 32) \
  --set kutt.defaultDomain=kutt.example.com
```

## Uninstalling the Chart

```bash
helm uninstall my-kutt
```

## Configuration

The following table lists the most important configurable parameters. See [values.yaml](values.yaml) for the complete list.

### Application

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kutt.defaultDomain` | The domain Kutt is hosted on | `""` |
| `kutt.auth.jwtSecret` | **Required.** JWT encryption secret | `""` |
| `kutt.auth.existingSecret` | Existing secret with `JWT_SECRET` key | `""` |
| `kutt.registration.disallowRegistration` | Disable user registration | `true` |
| `kutt.registration.disallowAnonymousLinks` | Disable anonymous link creation | `true` |

### Database

By default Kutt uses SQLite. Enable one of the sub-charts for a production database:

#### PostgreSQL

```yaml
postgresql:
  enabled: true
  auth:
    database: kutt
    username: kutt
    password: changeme
```

#### MariaDB

```yaml
mariadb:
  enabled: true
  auth:
    database: kutt
    username: kutt
    password: changeme
    rootPassword: changeme
```

#### External database

```yaml
kutt:
  db:
    client: pg         # or mysql2
    host: my-db-host
    port: "5432"
    name: kutt
    user: kutt
    password: changeme
```

### Redis

Redis is optional but recommended for rate-limiting and caching:

```yaml
redis:
  enabled: true
```

Or configure an external Redis:

```yaml
kutt:
  redis:
    enabled: true
    host: my-redis-host
    port: 6379
```

### Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: kutt.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: kutt-tls
      hosts:
        - kutt.example.com
```

## Dependencies

This chart has the following optional sub-chart dependencies managed via [Bitnami](https://bitnami.com/):

| Chart | Version | Condition |
|-------|---------|-----------|
| `bitnami/postgresql` | `>=16.0.0` | `postgresql.enabled` |
| `bitnami/mariadb` | `>=20.0.0` | `mariadb.enabled` |
| `bitnami/redis` | `>=20.0.0` | `redis.enabled` |

To download dependencies before installing:

```bash
helm dependency update helm/kutt
```
