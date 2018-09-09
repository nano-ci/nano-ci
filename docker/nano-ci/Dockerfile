FROM ruby:2.5-stretch AS nano-ci-base

WORKDIR /nano-ci

COPY ./nano-ci/Gemfile ./nano-ci/Gemfile.lock ./nano-ci/nanoci.gemspec /nano-ci/
COPY ./nano-ci/bin/nano-ci /nano-ci/bin/
COPY ./nano-ci/lib/nanoci/version.rb /nano-ci/lib/nanoci/

RUN bundler install --deployment

COPY ./nano-ci /nano-ci

ENV GEM_PATH=/nano-ci/gems

CMD ["ruby", "/nano-ci/bin/nano-ci"]

###

FROM nano-ci-base AS nano-ci-debug

RUN gem install ruby-debug-ide

EXPOSE 23456

CMD ["rdebug-ide", "--host", "0.0.0.0", "--port", "23456", "--", "/nano-ci/bin/nano-ci"]

###

FROM nano-ci-base AS nano-ci-self

COPY master.nanoci config.yml /nano-ci/

CMD ["ruby", "/nano-ci/bin/nano-ci", "--project", "/nano-ci/master.nanoci", "--config", "/nano-ci/config.yml"]
