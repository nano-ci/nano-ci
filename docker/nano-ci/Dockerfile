FROM ruby:2.5 AS nano-ci-base

WORKDIR /nano-ci

COPY ./nano-ci/Gemfile ./nano-ci/Gemfile.lock ./nano-ci/nanoci.gemspec /nano-ci/
COPY ./nano-ci/bin/nano-ci /nano-ci/bin/
COPY ./nano-ci/lib/nanoci/version.rb /nano-ci/lib/nanoci/

RUN apt-get install git && \
	gem install ruby-debug-ide && \
    bundle install --without development

COPY ./nano-ci /nano-ci

CMD ["ruby", "/nano-ci/bin/nano-ci"]

###

FROM nano-ci-base AS nano-ci-master

COPY config.yml /etc/nano-ci/
COPY master.nanoci nanoci.key /nano-ci-agent/

RUN chmod 400 /nano-ci-agent/nanoci.key

CMD ["ruby", "/nano-ci/bin/nano-ci", "--project=/nano-ci-agent/master.nanoci"]
