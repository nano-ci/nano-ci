FROM ruby:2.5-stretch

WORKDIR /nano-ci

COPY ./nano-ci/Gemfile ./nano-ci/Gemfile.lock ./nano-ci/nanoci.gemspec /nano-ci/
COPY ./nano-ci/bin/nano-ci /nano-ci/bin/
COPY ./nano-ci/lib/nanoci/version.rb /nano-ci/lib/nanoci/

RUN bundler install --deployment

COPY ./nano-ci /nano-ci

ENV GEM_PATH=/nano-ci/gems

CMD ["ruby", "/nano-ci/bin/nano-ci"]
