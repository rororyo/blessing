# syntax=docker/dockerfile:1

# ---- Build stage: Flutter web (version pinned to the one the app is built with)
FROM ghcr.io/cirruslabs/flutter:3.41.8 AS build
WORKDIR /app

# Resolve dependencies first so this layer is cached until pubspec changes.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter pub get && flutter build web --release --no-wasm-dry-run

# ---- Serve stage: nginx on Cloud Run's $PORT
FROM nginx:1.27-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
# The official image renders /etc/nginx/templates/*.template with the container's
# environment variables at start-up (that is how ${PORT} below is filled in).
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

ENV PORT=8080
EXPOSE 8080
