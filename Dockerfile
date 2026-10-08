# To refresh, copy the Digest from
# docker image inspect alpine:3.23.4 | jq -r '.[0].RepoDigests[0]'
FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

# bats: the test runner framework
# bash: the language
# bc:   used for float arithmetic
# coreutils: provides GNU version of tools like `date`
# gawk: used for float arithmetic
# jq:   used for JSON
RUN apk add --no-cache bats bash bc coreutils gawk jq

COPY . /opt/test-runner
WORKDIR /opt/test-runner
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

# $ docker build --rm -t exercism/bash-test-runner .
# $ docker run -it --entrypoint bash exercism/bash-test-runner -c 'for i in awk bash bats bc jq; do "$i" --version | head -n1; done'
# GNU Awk 5.3.2, API 4.0
# GNU bash, version 5.3.9(1)-release (x86_64-alpine-linux-musl)
# Bats 1.13.0
# bc 1.08.2
# jq-1.8.2
