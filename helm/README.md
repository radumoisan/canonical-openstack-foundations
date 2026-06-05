# Canonical OpenStack Foundations Helm Chart

This chart deploys the static training site container and an optional `oauth2-proxy` sidecar.

## Install

```shell
helm install canonical-openstack-foundations ./helm
```

## Notes

- Set `image.repository` and `image.tag` to the published site image you want to deploy.
- If `proxy.enabled` is `true`, oauth2-proxy uses Redis-backed sessions via the shared Redis service.
- `redis.enabled` only controls whether the Redis subchart is deployed; it does not change oauth2-proxy session storage.
