# pre-build stage
FROM node:23-alpine AS node
FROM ruby:3.4.4-alpine3.21 AS pre-builder

ARG NODE_VERSION="23.7.0"
ARG PNPM_VERSION="10.2.0"
ARG BUNDLE_WITHOUT="development:test"
ARG RAILS_SERVE_STATIC_FILES=true
ARG RAILS_ENV=production
ARG NODE_OPTIONS="--max-old-space-size=4096 --openssl-legacy-provider"

ENV NODE_VERSION=${NODE_VERSION} \
    PNPM_VERSION=${PNPM_VERSION} \
    BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
    BUNDLER_VERSION=2.5.11 \
    RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES} \
    RAILS_ENV=${RAILS_ENV} \
    NODE_OPTIONS=${NODE_OPTIONS} \
    BUNDLE_PATH="/gems"

RUN apk update && apk add --no-cache \
  openssl tar build-base tzdata postgresql-dev postgresql-client \
  git curl xz vips libxml2-dev libxslt-dev zlib-dev yaml-dev \
  libffi-dev protobuf protobuf-dev pkgconfig autoconf automake \
  libtool cmake python3 \
  && mkdir -p /var/app \
  && gem install bundler -v ${BUNDLER_VERSION}

COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && npm install -g pnpm@${PNPM_VERSION}

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local force_ruby_platform true

RUN bundle config set without "${BUNDLE_WITHOUT}" && \
    bundle install --jobs=4 --retry=3

COPY package.json pnpm-lock.yaml ./
RUN pnpm i

COPY . /app
RUN mkdir -p /app/log

RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle exec rails assets:precompile; \
    fi

RUN git rev-parse HEAD > /app/.git_sha && \
    rm -rf .git .gitignore

FROM ruby:3.4.4-alpine3.21

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_PATH="/gems" \
    RAILS_SERVE_STATIC_FILES=true

RUN apk update && apk add --no-cache \
  build-base openssl tzdata postgresql-client imagemagick git vips \
  && gem install bundler -v 2.5.11

COPY --from=pre-builder /gems/ /gems/
COPY --from=pre-builder /app /app
COPY --from=node /usr/local/bin/node /usr/local/bin/

WORKDIR /app
EXPOSE 3000
ENTRYPOINT ["docker/entrypoints/rails.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]