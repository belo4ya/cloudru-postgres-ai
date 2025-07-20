# Docker

Вдохновение:

- https://github.com/timescale/timescaledb-docker-ha/blob/master/Dockerfile
- https://github.com/tensorchord/cloudnative-vectorchord/blob/main/Dockerfile
- https://github.com/tensorchord/cloudnative-pgvecto.rs/blob/main/Dockerfile
- https://github.com/ChuckHend/pg_vectorize/blob/main/images/vectorize-pg/Dockerfile
- https://github.com/cloudnative-pg/postgres-containers/blob/main/Debian/16/bookworm/Dockerfile

```shell
❯ docker images | grep cloudnative
cloudnative-pg/postgresql           16.9-bookwarm-ai   c6eac4484ae2   5 minutes ago   2.02GB
ghcr.io/cloudnative-pg/postgresql   16.9               66ef5ec7f884   13 hours ago    893MB
ghcr.io/cloudnative-pg/postgresql   16.9-bookworm      9d655db43336   13 hours ago    971MB
```

Сборка:
```shell
apt-get update && apt-get upgrade

```
