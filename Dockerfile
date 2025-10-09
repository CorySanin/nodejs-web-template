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

HEALTHCHECK  --timeout=3s \
  CMD curl --fail http://localhost:8080/healthcheck || exit 1

EXPOSE 8080

WORKDIR /usr/src/app

RUN apk add --no-cache curl

COPY --from=build-env /usr/src/app /usr/src/app

USER node

CMD [ "node", "distribution/index.js"]
