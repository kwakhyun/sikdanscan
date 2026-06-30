# syntax=docker/dockerfile:1

FROM dart:stable AS build

WORKDIR /app

COPY server/pubspec.* ./
RUN dart pub get

COPY server/bin ./bin
COPY server/lib ./lib

RUN mkdir -p /app/build
RUN dart compile exe bin/sikdanscan_proxy.dart -o /app/build/sikdanscan_proxy

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/build/sikdanscan_proxy /app/sikdanscan_proxy

ENV PORT=8080
ENV DATABASE_PATH=/tmp/sikdanscan_proxy_db.json
ENV OPENAI_MODEL=gpt-5.4-mini
ENV PROXY_RATE_LIMIT_PER_MINUTE=60

EXPOSE 8080

CMD ["/app/sikdanscan_proxy"]
