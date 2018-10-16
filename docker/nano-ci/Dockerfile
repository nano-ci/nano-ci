FROM ruby:2.5-alpine AS nano-ci-base

WORKDIR /nano-ci

COPY ./nano-ci/Gemfile ./nano-ci/Gemfile.lock ./nano-ci/nanoci.gemspec /nano-ci/
COPY ./nano-ci/bin/nano-ci /nano-ci/bin/
COPY ./nano-ci/lib/nanoci/version.rb /nano-ci/lib/nanoci/

RUN apk add --no-cache build-base libstdc++ git openssh && \
	gem install ruby-debug-ide && \
    bundler install --without development && \
    apk del build-base

COPY ./nano-ci /nano-ci

CMD ["ruby", "/nano-ci/bin/nano-ci"]

###

FROM nano-ci-base AS nano-ci-self

COPY config.yml /nano-ci/
COPY master.nanoci nanoci.key /nano-ci-agent/

RUN chmod 400 /nano-ci-agent/nanoci.key

CMD ["ruby", "/nano-ci/bin/nano-ci", "--project", "/nano-ci-agent/master.nanoci", "--config", "/nano-ci/config.yml"]
