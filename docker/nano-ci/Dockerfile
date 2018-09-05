FROM ruby:2.5-stretch

WORKDIR /nano-ci
ADD . /nano-ci

RUN gem install /nano-ci/nanoci-0.1.0.gem -i /nano-ci

ENV GEM_PATH=/nano-ci/gems

CMD ["ruby", "/nano-ci/bin/nano-ci"]
