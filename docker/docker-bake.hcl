variable "IMAGE_NAME" {
  default = "belo4ya/cnpg-postgresql"
}

variable "PLATFORMS" {
  default = "linux/amd64,linux/arm64"
}

#https://github.com/cloudnative-pg/postgres-containers/pkgs/container/postgresql
variable "CNPG_PG15_TAG" { default = "15.13-bookworm" }
variable "CNPG_PG16_TAG" { default = "16.9-bookworm" }
variable "CNPG_PG17_TAG" { default = "17.5-bookworm" }

variable "PGVECTOR_VERSION" { default = "0.8.0-1.pgdg120+1" }
variable "PGVECTO_RS_VERSION" { default = "v0.4.0" }
variable "VECTORCHORD_VERSION" { default = "0.4.3" }
variable "PG_TOKENIZER_VERSION" { default = "0.1.0" }
variable "VECTORCHORD_BM25_VERSION" { default = "0.2.1" }
variable "LANTERN_VERSION" { default = "0.5.0" }
variable "PG_TIKTOKEN_VERSION" { default = "main" }
variable "PGRAG_VERSION" { default = "v0.1.2" }
variable "PG_SEARCH_VERSION" { default = "0.17.0" }
variable "PG_VECTORIZE_VERSION" { default = "v0.22.2" }
variable "PG_CRON_VERSION" { default = "1.6.5-1.pgdg120+1" }
variable "PGMQ_VERSION" { default = "v1.6.1" }
variable "PGVECTORSCALE_VERSION" { default = "0.8.0" }
variable "PGAI_VERSION" { default = "0.11.0" }

variable "PLPYTHON3U_VERSION_15" { default = "15.13-1.pgdg120+1" }
variable "PLPYTHON3U_VERSION_16" { default = "16.9-1.pgdg120+1" }
variable "PLPYTHON3U_VERSION_17" { default = "17.5-1.pgdg120+1" }

group "args_common" {
  targets = []
}

target "pg15" {
  context    = "."
  dockerfile = "bookworm.Dockerfile"
  platforms = ["${PLATFORMS}"]
  tags = ["${IMAGE_NAME}:${CNPG_PG15_TAG}-ai"]
  args = {
    CNPG_TAG                 = "${CNPG_PG15_TAG}"
    PGVECTOR_VERSION         = "${PGVECTOR_VERSION}"
    PGVECTO_RS_VERSION       = "${PGVECTO_RS_VERSION}"
    VECTORCHORD_VERSION      = "${VECTORCHORD_VERSION}"
    PG_TOKENIZER_VERSION     = "${PG_TOKENIZER_VERSION}"
    VECTORCHORD_BM25_VERSION = "${VECTORCHORD_BM25_VERSION}"
    LANTERN_VERSION          = "${LANTERN_VERSION}"
    PG_TIKTOKEN_VERSION      = "${PG_TIKTOKEN_VERSION}"
    PGRAG_VERSION            = "${PGRAG_VERSION}"
    PG_SEARCH_VERSION        = "${PG_SEARCH_VERSION}"
    PG_VECTORIZE_VERSION     = "${PG_VECTORIZE_VERSION}"
    PG_CRON_VERSION          = "${PG_CRON_VERSION}"
    PGMQ_VERSION             = "${PGMQ_VERSION}"
    PGVECTORSCALE_VERSION    = "${PGVECTORSCALE_VERSION}"
    PGAI_VERSION             = "${PGAI_VERSION}"
    PLPYTHON3U_VERSION       = "${PLPYTHON3U_VERSION_15}"
  }
  cache-from = ["type=registry,ref=${IMAGE_NAME}:${CNPG_PG15_TAG}-ai-buildcache"]
  cache-to = ["type=registry,ref=${IMAGE_NAME}:${CNPG_PG15_TAG}-ai-buildcache,mode=max"]
}

target "pg16" {
  inherits = ["pg15"]
  tags = ["${IMAGE_NAME}:${CNPG_PG16_TAG}-ai"]
  args = {
    CNPG_TAG           = "${CNPG_PG16_TAG}"
    PLPYTHON3U_VERSION = "${PLPYTHON3U_VERSION_16}"
  }
  cache-from = ["type=registry,ref=${IMAGE_NAME}:${CNPG_PG16_TAG}-ai-buildcache"]
  cache-to = ["type=registry,ref=${IMAGE_NAME}:${CNPG_PG16_TAG}-ai-buildcache,mode=max"]
}

target "pg17" {
  inherits = ["pg15"]
  tags = ["${IMAGE_NAME}:${CNPG_PG17_TAG}-ai"]
  args = {
    CNPG_TAG           = "${CNPG_PG17_TAG}"
    PLPYTHON3U_VERSION = "${PLPYTHON3U_VERSION_17}"
  }
  cache-from = ["type=registry,ref=${IMAGE_NAME}:${CNPG_PG17_TAG}-ai-buildcache"]
  cache-to = ["type=registry,ref=${IMAGE_NAME}:${CNPG_PG17_TAG}-ai-buildcache,mode=max"]
}

group "default" {
  targets = ["pg16"]
}

group "all" {
  targets = ["pg15", "pg16", "pg17"]
}
