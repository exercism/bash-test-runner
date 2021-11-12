FROM ubuntu:20.04

# Specifically use bats 1.5.0
# Remove git when we're done with it.
# Other commands to add to environment, might be used by students
#   - bc
#   - awk
#   - sed

RUN apt-get update && \
    apt-get install -y git bc gawk sed jq && \
    git clone https://github.com/bats-core/bats-core && \
    cd bats-core && \
    git checkout v1.5.0 && \
    bash ./install.sh /usr/local && \
    cd && \
    apt-get remove -y git && \
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/test-runner
WORKDIR /opt/test-runner
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
