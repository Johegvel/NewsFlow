# syntax = docker/dockerfile:1

# Base stage
ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Build stage to install gems
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev git pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Final stage for app image
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Fix potential Windows CRLF endings and ensure executable permissions on bin scripts
RUN sed -i 's/\r$//' /rails/bin/* && \
    chmod +x /rails/bin/*

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    rm -rf /rails/tmp/cache/* && \
    mkdir -p /rails/tmp/pids /rails/tmp/sockets /rails/tmp/cache && \
    chown -R rails:rails /rails
USER 1000:1000

# Cloud Run injects PORT (defaults to 8080 or 3000)
ENV PORT=8080
EXPOSE 8080

# Entrypoint prepares the database and boots Puma
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
