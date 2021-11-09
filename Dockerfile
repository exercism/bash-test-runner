FROM ubuntu:20.04

# Specifically use bats 1.5.0

RUN apt-get update && \
    apt-get install -y git bc gawk sed && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/bats-core/bats-core && \
    cd bats-core && \
    git checkout v1.5.0 && \
    bash ./install.sh /usr/local && cd

COPY . /opt/test-runner
WORKDIR /opt/test-runner
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
