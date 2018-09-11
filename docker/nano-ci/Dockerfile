FROM ruby:2.5-alpine AS nano-ci-base

WORKDIR /nano-ci

COPY ./nano-ci/Gemfile ./nano-ci/Gemfile.lock ./nano-ci/nanoci.gemspec /nano-ci/
COPY ./nano-ci/bin/nano-ci /nano-ci/bin/
COPY ./nano-ci/lib/nanoci/version.rb /nano-ci/lib/nanoci/

RUN apk add --no-cache build-base && \
    apk add --no-cache libstdc++ && \
    bundler install --deployment --without development && \
    gem install ruby-debug-ide && \
    apk del build-base

COPY ./nano-ci /nano-ci

ENV GEM_PATH=/nano-ci/gems

CMD ["ruby", "/nano-ci/bin/nano-ci"]

###

FROM nano-ci-base AS nano-ci-debug

EXPOSE 23456

CMD ["rdebug-ide", "--host", "0.0.0.0", "--port", "23456", "--", "/nano-ci/bin/nano-ci"]

###

FROM nano-ci-base AS nano-ci-self

COPY master.nanoci config.yml /nano-ci/

CMD ["ruby", "/nano-ci/bin/nano-ci", "--project", "/nano-ci/master.nanoci", "--config", "/nano-ci/config.yml"]
