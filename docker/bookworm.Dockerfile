ARG CNPG_TAG=16.9-bookworm
FROM ghcr.io/cloudnative-pg/postgresql:$CNPG_TAG AS builder

ARG TARGETARCH
#https://github.com/cloudnative-pg/postgres-containers/pkgs/container/postgresql
ARG CNPG_TAG=16.9-bookworm
ENV PG_MAJOR=${CNPG_TAG%.*}

#pgvector
ARG PGVECTOR_VERSION=0.8.0-1.pgdg120+1
#https://github.com/tensorchord/pgvecto.rs
ARG PGVECTO_RS_VERSION=v0.4.0
#https://github.com/tensorchord/VectorChord
ARG VECTORCHORD_VERSION=0.4.3
#https://github.com/tensorchord/pg_tokenizer.rs
ARG PG_TOKENIZER_VERSION=0.1.0
#https://github.com/tensorchord/VectorChord-bm25
ARG VECTORCHORD_BM25_VERSION=0.2.1
#https://github.com/lanterndata/lantern
ARG LANTERN_VERSION=0.5.0
#https://github.com/kelvich/pg_tiktoken
ARG PG_TIKTOKEN_VERSION=main
#https://github.com/neondatabase-labs/pgrag
ARG PGRAG_VERSION=v0.1.2
#https://github.com/paradedb/paradedb/tree/main/pg_search
ARG PG_SEARCH_VERSION=v0.17.0

#https://github.com/ChuckHend/pg_vectorize
ARG PG_VECTORIZE_VERSION=v0.22.2
#https://github.com/citusdata/pg_cron
ARG PG_CRON_VERSION=1.6.5-1.pgdg120+1
#https://github.com/pgmq/pgmq
ARG PGMQ_VERSION=v1.6.1

#https://github.com/timescale/pgvectorscale
ARG PGVECTORSCALE_VERSION=0.8.0
#https://github.com/timescale/pgai
ARG PGAI_VERSION=0.11.0
#plpython3u
ARG PLPYTHON3U_VERSION=16.9-1.pgdg120+1

USER root

RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/01norecommend
RUN echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/01norecommend

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    ca-certificates gnupg1 gpg gpg-agent locales lsb-release \
	curl wget unzip jq git

RUN git config --global advice.detachedHead false

RUN apt-get install -y postgresql-server-dev-${PG_MAJOR}

ENV BUILD_PACKAGES="binutils cmake devscripts equivs gcc git gpg gpg-agent libc-dev libc6-dev libkrb5-dev libperl-dev libssl-dev lsb-release make patchutils python3-dev wget libsodium-dev"
ENV BUILD_PACKAGES="$BUILD_PACKAGES clang pkg-config build-essential zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev tk-dev libncurses5-dev libgdbm-dev libnss3-dev libicu-dev libclang-dev ninja-build python3-flatbuffers protobuf-compiler"
RUN apt-get install -y ${BUILD_PACKAGES}
RUN apt-mark auto ${BUILD_PACKAGES}

RUN apt-get install -y python3 python3-pip \
    && pip3 install --break-system-packages uv

WORKDIR /build

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# ===================== EXTENSIONS =====================

# --------------------- pgvector
RUN apt-get install -y postgresql-${PG_MAJOR}-pgvector=$PGVECTOR_VERSION

# --------------------- https://github.com/tensorchord/pgvecto.rs
# 450MB before stripping, 12MB after
ADD https://github.com/tensorchord/pgvecto.rs/releases/download/$PGVECTO_RS_VERSION/vectors-pg${PG_MAJOR}_${PGVECTO_RS_VERSION#"v"}_${TARGETARCH}.deb /tmp/pgvectors.deb
RUN apt-get install -y /tmp/pgvectors.deb \
    && rm -f /tmp/pgvectors.deb

# --------------------- https://github.com/tensorchord/VectorChord
# 93MB before stripping, 3.5MB after
ADD https://github.com/tensorchord/VectorChord/releases/download/$VECTORCHORD_VERSION/postgresql-${PG_MAJOR}-vchord_${VECTORCHORD_VERSION#"v"}-1_${TARGETARCH}.deb /tmp/vchord.deb
RUN apt-get install -y /tmp/vchord.deb \
    && rm -f /tmp/vchord.deb

# --------------------- https://github.com/tensorchord/pg_tokenizer.rs
ADD https://github.com/tensorchord/pg_tokenizer.rs/releases/download/$PG_TOKENIZER_VERSION/postgresql-${PG_MAJOR}-pg-tokenizer_${PG_TOKENIZER_VERSION}-1_${TARGETARCH}.deb /tmp/pg_tokenizer.deb
RUN apt-get install -y /tmp/pg_tokenizer.deb \
    && rm -f /tmp/pg_tokenizer.deb

# --------------------- https://github.com/tensorchord/VectorChord-bm25
ADD https://github.com/tensorchord/VectorChord-bm25/releases/download/$VECTORCHORD_BM25_VERSION/postgresql-${PG_MAJOR}-vchord-bm25_${VECTORCHORD_BM25_VERSION}-1_${TARGETARCH}.deb /tmp/vchord_bm25.deb
RUN apt-get install -y /tmp/vchord_bm25.deb \
    && rm -f /tmp/vchord_bm25.deb

# --------------------- https://github.com/timescale/pgvectorscale
RUN git clone --branch ${PGVECTORSCALE_VERSION} https://github.com/timescale/pgvectorscale \
    && cd pgvectorscale/pgvectorscale \
    && cargo install --locked cargo-pgrx --version $(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "pgrx") | .version') \
    && cargo pgrx init --pg${PG_MAJOR} $(which pg_config) \
    && cargo pgrx install --release

# --------------------- https://github.com/kelvich/pg_tiktoken
RUN git clone --branch ${PG_TIKTOKEN_VERSION} https://github.com/kelvich/pg_tiktoken \
    && cd pg_tiktoken \
    && cargo install --locked cargo-pgrx --version $(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "pgrx") | .version') \
    && cargo pgrx init --pg${PG_MAJOR} $(which pg_config) \
    && cargo pgrx install --release

# --------------------- https://github.com/lanterndata/lantern
ADD https://github.com/lanterndata/lantern/releases/download/v${LANTERN_VERSION}/lantern-${LANTERN_VERSION}.tar lantern-${LANTERN_VERSION}.tar
RUN tar -xf lantern-${LANTERN_VERSION}.tar \
    && cd lantern-${LANTERN_VERSION} \
    && make install \
    && cd .. && rm -rf lantern-${LANTERN_VERSION}

# --------------------- https://github.com/paradedb/paradedb/tree/main/pg_search
ADD https://github.com/paradedb/paradedb/releases/download/v$PG_SEARCH_VERSION/postgresql-${PG_MAJOR}-pg-search_${PG_SEARCH_VERSION#"v"}-1PARADEDB-bookworm_${TARGETARCH}.deb /tmp/pg_search.deb
RUN apt-get install -y /tmp/pg_search.deb \
    && rm -f /tmp/pg_search.deb

# --------------------- https://github.com/ChuckHend/pg_vectorize

# https://github.com/citusdata/pg_cron
RUN apt-get install -y postgresql-${PG_MAJOR}-cron=${PG_CRON_VERSION}

# https://github.com/pgmq/pgmq
RUN git clone --branch=${PGMQ_VERSION} https://github.com/pgmq/pgmq.git \
    && cd pgmq/pgmq-extension \
    && make && make install

# pg_vectorize
RUN git clone --branch=${PG_VECTORIZE_VERSION} https://github.com/ChuckHend/pg_vectorize.git \
    && cd pg_vectorize/extension \
    && cargo install --locked cargo-pgrx --version $(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "pgrx") | .version') \
    && cargo pgrx init --pg${PG_MAJOR} $(which pg_config) \
    && cargo pgrx install --release

# --------------------------------------------------------------------------------------

# --------------------- https://github.com/timescale/pgai

# plpython3u
RUN apt-get install -y postgresql-plpython3-${PG_MAJOR}=${PLPYTHON3U_VERSION}

# pgai
RUN git clone --branch extension-${PGAI_VERSION} https://github.com/timescale/pgai.git \
    && cd pgai \
    && projects/extension/build.py install

# --------------------------------------------------------------------------------------

# --------------------- https://github.com/neondatabase-labs/pgrag

#https://github.com/microsoft/onnxruntime/issues/25098
ADD https://github.com/microsoft/onnxruntime/archive/refs/tags/v1.18.1.tar.gz onnxruntime-1.18.1.tar.gz
RUN apt remove cmake -y && uv tool install 'cmake<4.0.0' \
    && export PATH="$(uv -q tool dir)/cmake/bin:$PATH" \
    && tar -xzf onnxruntime-1.18.1.tar.gz && rm -rf onnxruntime-1.18.1.tar.gz && cd onnxruntime-1.18.1 \
    && sed -i 's/be8be39fdbc6e60e94fa7870b280707069b5b81a/32b145f525a8308d7ab1c09388b2e288312d8eba/g' cmake/deps.txt \
    && ./build.sh --config Release --parallel --skip_submodule_sync --skip_tests --allow_running_as_root

RUN git clone --branch ${PGRAG_VERSION} https://github.com/neondatabase-labs/pgrag.git \
    && cd pgrag \
    && cd lib/bge_small_en_v15 && tar -xzf model.onnx.tar.gz && cd ../.. \
    && cd lib/jina_reranker_v1_tiny_en && tar -xzf model.onnx.tar.gz && cd ../.. \
    && cd exts/rag \
    && cargo install --locked cargo-pgrx --version $(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "pgrx") | .version') \
    && cargo pgrx init --pg${PG_MAJOR} $(which pg_config) \
    && cargo pgrx install --release \
    && cd ../rag_bge_small_en_v15 \
    && ORT_LIB_LOCATION=/build/onnxruntime-1.18.1/build/Linux cargo pgrx install --release \
    && cd ../rag_jina_reranker_v1_tiny_en \
    && ORT_LIB_LOCATION=/build/onnxruntime-1.18.1/build/Linux cargo pgrx install --release \
    && cd ../../.. && rm -rf pgrag onnxruntime-1.18.1

# --------------------------------------------------------------------------------------

RUN set -e; \
  for so in \
    lantern_extras.so \
    lantern.so \
    pg_tiktoken.so \
    pg_tokenizer.so \
    rag.so \
    rag_bge_small_en_v15.so \
    rag_jina_reranker_v1_tiny_en.so \
    vchord.so \
    vectorize.so \
    vectors.so \
    vchord_bm25.so \
    pg_search.so \
  ; do \
    file="/usr/lib/postgresql/${PG_MAJOR}/lib/$so"; \
    strip --strip-unneeded "$file" || echo "Warn: strip failed for $file" >&2; \
  done

RUN apt-get clean

FROM builder AS trimmed

ENV BUILD_PACKAGES="binutils cmake devscripts equivs gcc git gpg gpg-agent libc-dev libc6-dev libkrb5-dev libperl-dev libssl-dev lsb-release make patchutils python3-dev wget libsodium-dev"
ENV BUILD_PACKAGES="$BUILD_PACKAGES clang pkg-config build-essential zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev tk-dev libncurses5-dev libgdbm-dev libnss3-dev"

RUN uv tool uninstall cmake || true && \
    apt-get purge -y ${BUILD_PACKAGES} && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
              /build \
              /var/cache/debconf/* \
              /usr/include \
              /usr/share/doc \
              /usr/share/man \
              /usr/share/info \
              /usr/share/locale/?? \
              /usr/share/locale/??_?? \
              /usr/local/rustup \
              /usr/local/cargo \
              /root/.cache \
              /root/.cargo \
              /root/.rustup \
              /root/.pgrx \
              /root/.bashrc \
              /usr/lib/python3*/test \
    && find /var/log -type f -exec truncate --size 0 {} \;

ARG CNPG_TAG=16.9-bookworm
FROM ghcr.io/cloudnative-pg/postgresql:$CNPG_TAG

COPY --from=trimmed / /

ARG CNPG_TAG=16.9-bookworm
ARG PGVECTOR_VERSION=0.8.0-1.pgdg120+1
ARG PGVECTO_RS_VERSION=v0.4.0
ARG VECTORCHORD_VERSION=0.4.3
ARG PG_TOKENIZER_VERSION=0.1.0
ARG VECTORCHORD_BM25_VERSION=0.2.1
ARG LANTERN_VERSION=0.5.0
ARG PG_TIKTOKEN_VERSION=main
ARG PGRAG_VERSION=v0.1.2
ARG PG_SEARCH_VERSION=v0.17.0
ARG PG_VECTORIZE_VERSION=v0.22.2
ARG PG_CRON_VERSION=1.6.5-1.pgdg120+1
ARG PGMQ_VERSION=v1.6.1
ARG PGVECTORSCALE_VERSION=0.8.0
ARG PGAI_VERSION=0.11.0
ARG PLPYTHON3U_VERSION=16.9-1.pgdg120+1

LABEL ru.cloud.postgresql.cnpg_tag="${CNPG_TAG}" \
      ru.cloud.postgresql.ext.pgvector="${PGVECTOR_VERSION}" \
      ru.cloud.postgresql.ext.pgvecto_rs="${PGVECTO_RS_VERSION}" \
      ru.cloud.postgresql.ext.vectorchord="${VECTORCHORD_VERSION}" \
      ru.cloud.postgresql.ext.pg_tokenizer="${PG_TOKENIZER_VERSION}" \
      ru.cloud.postgresql.ext.vectorchord_bm25="${VECTORCHORD_BM25_VERSION}" \
      ru.cloud.postgresql.ext.lantern="${LANTERN_VERSION}" \
      ru.cloud.postgresql.ext.pg_tiktoken="${PG_TIKTOKEN_VERSION}" \
      ru.cloud.postgresql.ext.pgrag="${PGRAG_VERSION}" \
      ru.cloud.postgresql.ext.pg_search="${PG_SEARCH_VERSION}" \
      ru.cloud.postgresql.ext.pg_vectorize="${PG_VECTORIZE_VERSION}" \
      ru.cloud.postgresql.ext.pg_cron="${PG_CRON_VERSION}" \
      ru.cloud.postgresql.ext.pgmq="${PGMQ_VERSION}" \
      ru.cloud.postgresql.ext.pgvectorscale="${PGVECTORSCALE_VERSION}" \
      ru.cloud.postgresql.ext.pgai="${PGAI_VERSION}" \
      ru.cloud.postgresql.ext.plpython3u="${PLPYTHON3U_VERSION}"

USER root

RUN set -eu; \
    mkdir -p /opt/cloudru/postgresql; \
    { \
      echo "CNPG_TAG=${CNPG_TAG}"; \
      echo "PGVECTOR_VERSION=${PGVECTOR_VERSION}"; \
      echo "PGVECTO_RS_VERSION=${PGVECTO_RS_VERSION}"; \
      echo "VECTORCHORD_VERSION=${VECTORCHORD_VERSION}"; \
      echo "PG_TOKENIZER_VERSION=${PG_TOKENIZER_VERSION}"; \
      echo "VECTORCHORD_BM25_VERSION=${VECTORCHORD_BM25_VERSION}"; \
      echo "LANTERN_VERSION=${LANTERN_VERSION}"; \
      echo "PG_TIKTOKEN_VERSION=${PG_TIKTOKEN_VERSION}"; \
      echo "PGRAG_VERSION=${PGRAG_VERSION}"; \
      echo "PG_SEARCH_VERSION=${PG_SEARCH_VERSION}"; \
      echo "PG_VECTORIZE_VERSION=${PG_VECTORIZE_VERSION}"; \
      echo "PG_CRON_VERSION=${PG_CRON_VERSION}"; \
      echo "PGMQ_VERSION=${PGMQ_VERSION}"; \
      echo "PGVECTORSCALE_VERSION=${PGVECTORSCALE_VERSION}"; \
      echo "PGAI_VERSION=${PGAI_VERSION}"; \
      echo "PLPYTHON3U_VERSION=${PLPYTHON3U_VERSION}"; \
    } > /opt/cloudru/postgresql/build-info.txt

USER postgres
