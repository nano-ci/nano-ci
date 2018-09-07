FROM ruby:2.5-stretch

WORKDIR /nano-ci
ADD ./nano-ci /nano-ci

RUN bundler install --deployment

ENV GEM_PATH=/nano-ci/gems

CMD ["ruby", "/nano-ci/bin/nano-ci"]
