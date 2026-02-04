# --- Stage 1: Node.js assets ---
FROM node:23-alpine AS node-assets
# Giai đoạn này chỉ để lấy node/npm/pnpm nếu cần build riêng, 
# nhưng chúng ta sẽ gộp vào pre-builder để thuận tiện cho Rails.

# --- Stage 2: Pre-builder (Cài đặt và Build) ---
FROM ruby:3.4.4-alpine3.21 AS pre-builder

# Khai báo các biến Build-time
ARG NODE_VERSION="23.7.0"
ARG PNPM_VERSION="10.2.0"
ARG RAILS_ENV=production
ARG BUNDLE_WITHOUT="development:test"
ARG NODE_OPTIONS="--max-old-space-size=4096 --openssl-legacy-provider"

# Thiết lập biến môi trường cho quá trình Build
ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
    NODE_OPTIONS=${NODE_OPTIONS} \
    BUNDLE_PATH="/gems" \
    BUNDLE_FORCE_RUBY_PLATFORM=1

RUN apk update && apk add --no-cache \
  openssl tar build-base tzdata postgresql-dev postgresql-client \
  git curl xz vips libxml2-dev libxslt-dev zlib-dev yaml-dev \
  libffi-dev protobuf protobuf-dev pkgconfig autoconf automake \
  libtool cmake python3

# Cài đặt Node.js từ Image node chính thức
COPY --from=node:23-alpine /usr/local/bin/node /usr/local/bin/
COPY --from=node:23-alpine /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && npm install -g pnpm@${PNPM_VERSION}

WORKDIR /app

# Cài đặt Gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.11 && \
    bundle config set --local force_ruby_platform true && \
    bundle config set --local without "${BUNDLE_WITHOUT}" && \
    bundle install --jobs=2 --retry=3 --verbose 2>&1 | tee /tmp/bundle-install.log || (cat /tmp/bundle-install.log && exit 1)

# Cài đặt Node packages
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile || pnpm install

# Copy toàn bộ code và Build Assets
COPY . .
RUN mkdir -p /app/log
RUN if [ "$RAILS_ENV" = "production" ]; then \
      SECRET_KEY_BASE=precompile_placeholder \
      RAILS_LOG_TO_STDOUT=enabled \
      bundle exec rake assets:precompile && \
      rm -rf spec node_modules tmp/cache; \
    fi

# Lưu thông tin Git Commit
RUN git rev-parse HEAD > /app/.git_sha && \
    rm -rf .git .gitignore

# --- Stage 3: Final Image (Runtime) ---
FROM ruby:3.4.4-alpine3.21

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_PATH="/gems" \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# Cài đặt các thư viện cần thiết để chạy App (Runtime dependencies)
RUN apk update && apk add --no-cache \
  build-base openssl tzdata postgresql-client imagemagick git vips \
  && gem install bundler -v 2.5.11

# Copy các thành phần đã build từ stage trước
COPY --from=pre-builder /gems/ /gems/
COPY --from=pre-builder /app /app
COPY --from=node:23-alpine /usr/local/bin/node /usr/local/bin/

WORKDIR /app

# Phân quyền cho entrypoint
RUN chmod +x docker/entrypoints/rails.sh

EXPOSE 3000

# Sử dụng Entrypoint để quản lý PID và khởi tạo
ENTRYPOINT ["docker/entrypoints/rails.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]