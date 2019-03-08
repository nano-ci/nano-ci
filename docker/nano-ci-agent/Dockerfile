FROM nano-ci AS nano-ci-agent

RUN gem install rspec

COPY config.yml /etc/nano-ci/
COPY nanoci.key /nano-ci-agent/

RUN chmod 400 /nano-ci-agent/nanoci.key


CMD ["ruby", "/nano-ci/bin/nano-ci-agent"]
