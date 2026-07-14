# Canonical OpenStack Foundations Helm Chart

This chart deploys the static training site container and an optional `oauth2-proxy` sidecar.

## Install

```shell
helm install canonical-openstack-foundations ./helm
```

## Configuration

### Proxy Secrets

Sensitive proxy values can be sourced from Kubernetes Secrets or supplied as plain values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `proxy.keycloak.secret_name` | Secret name for Keycloak client secret | `""` (empty — plaintext fallback) |
| `proxy.keycloak.client_secret_key` | Key within the Keycloak secret | `client-secret` |
| `proxy.cookie.secret_name` | Secret name for cookie secret | `""` (empty — plaintext fallback) |
| `proxy.cookie.secret_key` | Key within the cookie secret | `cookie-secret` |
| `proxy.redis.enabled` | Enable Redis session store env vars in oauth2-proxy | `true` |
| `proxy.redis.connection_url` | Redis connection URL for oauth2-proxy sessions | `redis://redis-master:6379` |
| `proxy.redis.secret_name` | Secret name for Redis password | `redis` |
| `proxy.redis.secret_key` | Key within the Redis secret | `password` |

### Backward Compatibility (Deprecated)

When secret names are empty the chart falls back to plain values (deprecated — configure `secret_name` for deployment):

- `proxy.keycloak.secret_name` empty → uses `proxy.CLIENT_SECRET`
- `proxy.cookie.secret_name` empty → uses `proxy.COOKIE_SECRET`
- `proxy.redis.connection_url` empty → constructs URL from `redis.fullnameOverride`
- `proxy.redis.secret_name` empty → uses `redis.auth.existingSecret` / `redis.auth.existingSecretPasswordKey`

### Redis

- `redis.enabled` controls **only** whether the embedded Redis subchart is deployed (Chart.yaml dependency condition).
- `proxy.redis.enabled` controls whether oauth2-proxy receives Redis session-store environment variables (`OAUTH2_PROXY_SESSION_STORE_TYPE`, `OAUTH2_PROXY_REDIS_CONNECTION_URL`, `OAUTH2_PROXY_REDIS_PASSWORD`).
- The two flags are independent. Typical external-Redis pattern: `redis.enabled=false`, `proxy.redis.enabled=true` with `proxy.redis.connection_url` pointing at the external instance.

### Client ID

`proxy.CLIENT_ID` remains a plain value (not a secret reference).

## Notes

- Set `image.repository` and `image.tag` to the published site image you want to deploy.
- If `proxy.enabled` is `true` and `proxy.redis.enabled` is `true`, oauth2-proxy uses Redis-backed sessions.
