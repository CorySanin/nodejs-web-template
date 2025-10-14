FROM node:lts-alpine AS base

FROM base AS build-env

WORKDIR /usr/src/app

RUN apk add --no-cache libwebp libwebp-tools libavif-apps

COPY package*.json ./

RUN npm install

COPY . .

RUN npx tsc && npm run-script build && \
  npm ci --only=production && \
  ln -sf /usr/share/fonts assets/ && \
  chown -R node .

FROM base AS deploy

ARG version=develop
ARG githash=REVISION
ARG created=CREATED

LABEL org.opencontainers.image.title="nodejs-web-template"
LABEL org.opencontainers.image.description="Template for my nodejs web projects"
LABEL org.opencontainers.image.authors="Cory Sanin <corysanin@outlook.com>"
LABEL org.opencontainers.image.url="https://git.sanin.dev/corysanin/nodejs-web-template"
LABEL org.opencontainers.image.documentation="https://git.sanin.dev/corysanin/nodejs-web-template"
LABEL org.opencontainers.image.source="https://git.sanin.dev/corysanin/nodejs-web-template"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version="${version}"
LABEL org.opencontainers.image.revision="${githash}"
LABEL org.opencontainers.image.created="${created}"

HEALTHCHECK  --timeout=3s \
  CMD curl --fail http://localhost:8080/healthcheck || exit 1

EXPOSE 8080

WORKDIR /usr/src/app

RUN apk add --no-cache curl

COPY --from=build-env /usr/src/app /usr/src/app

USER node

CMD [ "node", "distribution/index.js"]
