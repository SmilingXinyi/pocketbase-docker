FROM alpine:3 as downloader

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

# 生成文件名用的版本号（去掉前缀 v）
ENV VER_NO_V="${VERSION#v}"

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}${TARGETVARIANT}"

RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${VER_NO_V}/pocketbase_${VER_NO_V}_${BUILDX_ARCH}.zip \
    && unzip pocketbase_${VER_NO_V}_${BUILDX_ARCH}.zip \
    && chmod +x /pocketbase

FROM alpine:3
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

EXPOSE 80

COPY --from=downloader /pocketbase /usr/local/bin/pocketbase
ENTRYPOINT ["/usr/local/bin/pocketbase", "serve", "--http=0.0.0.0:80", "--dir=/pb_data", "--publicDir=/pb_public", "--migrationsDir=/pb_migrations"]