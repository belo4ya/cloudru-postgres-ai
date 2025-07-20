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

| Extension / PostgreSQL                                                        | 17.5 | 16.9    | 15.13 |
|-------------------------------------------------------------------------------|------|---------|-------|
| [pgvector/pgvector](https://github.com/pgvector/pgvector)                     |      | 0.8.0   |       |
| [timescale/pgvectorscale](https://github.com/timescale/pgvectorscale)         |      | 0.8.0   |       |
| [timescale/pgai](https://github.com/timescale/pgai)                           |      | 0.11.0  |       |
| [tensorchord/VectorChord](https://github.com/tensorchord/VectorChord/)        |      | 0.4.3   |       |
| [tensorchord/pgvecto.rs](https://github.com/tensorchord/pgvecto.rs)           |      | 0.4.0   |       |
| [ChuckHend/pg_vectorize](https://github.com/ChuckHend/pg_vectorize)           |      | 0.22.2  |       |
| [neondatabase-labs/pgrag](https://github.com/neondatabase-labs/pgrag)         |      | 0.1.2   |       |
| [lanterndata/lantern](https://github.com/lanterndata/lantern)                 |      | 0.5.0   |       |
| [kelvich/pg_tiktoken](https://github.com/kelvich/pg_tiktoken)                 |      | 9118dd4 |       |
| [tensorchord/pg_tokenizer.rs](https://github.com/tensorchord/pg_tokenizer.rs) |      | 0.1.0   |       |
| [paradedb/paradedb/pg_search](https://github.com/paradedb/paradedb)           |      | 0.17.0  |       |
| [VectorChord-bm25](https://github.com/tensorchord/VectorChord-bm25)           |      | 0.2.1   |       |
| Зависимости                                                                   |      |         |       |
| [citusdata/pg_cron](https://github.com/citusdata/pg_cron)                     |      | 1.6.5   |       |
| [pgmq/pgmq](https://github.com/pgmq/pgmq)                                     |      | 1.6.1   |       |
| [plpython3u](https://www.postgresql.org/docs/current/plpython.html)           |      | 16.9    |       |

Сборка:

```shell
sudo su
apt-get update && apt-get upgrade && apt install -y git make

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

git clone https://github.com/belo4ya/cloudru-postgres-ai.git && cd cloudru-postgres-ai/docker

docker login -u belo4ya

make builder release
```
