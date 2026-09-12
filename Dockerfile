# Pokemon Showdown on Railway
# Upstream is cloned at the pinned commit in UPSTREAM_PIN (also baked in as a build arg
# default so the build is reproducible even without buildkit reading extra files).
ARG NODE_IMAGE=node:22-slim

FROM ${NODE_IMAGE} AS build
ARG SHOWDOWN_COMMIT=aa17ca0fac8bc5605df673bd8774c2d0e91efa43
WORKDIR /build
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/smogon/pokemon-showdown.git . \
    && git checkout "${SHOWDOWN_COMMIT}"
RUN npm install --omit=dev --ignore-scripts \
    && node build

FROM ${NODE_IMAGE}
LABEL org.opencontainers.image.title="pokemon-showdown-railway" \
      org.opencontainers.image.description="Self-hosted Pokemon Showdown battle server, packaged for Railway" \
      org.opencontainers.image.source="https://github.com/smogon/pokemon-showdown"
WORKDIR /app
COPY --from=build /build /app
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh \
    && if [ ! -f /app/config/config.js ]; then cp /app/config/config-example.js /app/config/config.js; fi \
    && cp -a /app/config /app/config-dist
ENV PORT=8000
EXPOSE 8000
CMD ["/app/start.sh"]
