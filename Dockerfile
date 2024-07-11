FROM ubuntu:24.04

# Ubuntu 24.04 ships with bash version 5.2
# https://hub.docker.com/layers/library/ubuntu/24.04/images/sha256-3963c438d67a34318a3672faa6debd1dfff48e5d52de54305988b932c61514ca?context=explore
# 24.04 provides bats v1.10.0
# Test runner needs jq.
# Other commands to add to environment, might be used by students
#   - bc
#   - GNU awk (Ubuntu 20.04 ships with mawk)
# Tools commonly used by students that will already be installed include:
#   - sed, tr, ...

RUN apt-get update                      && \
    apt-get install -y bats jq bc gawk  && \
    apt-get purge --auto-remove -y      && \
    apt-get clean                       && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/test-runner
WORKDIR /opt/test-runner
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
