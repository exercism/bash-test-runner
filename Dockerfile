# Debian's bash links against glibc. Alpine's bash links against musl, and
# musl's memory allocator is slow for the way bats uses bash: bats runs about
# 2,000 bash commands for each test, and each one allocates and frees memory.
# An empty file of 50 tests takes 2.35s on Alpine and 1.43s here.
#
# To refresh, copy the Digest from
# docker image inspect debian:trixie-slim | jq -r '.[0].RepoDigests[0]'
FROM debian:trixie-slim@sha256:109e2c65005bf160609e4ba6acf7783752f8502ad218e298253428690b9eaa4b

# bats: the test runner framework
# bc:   used for float arithmetic
# gawk: used for float arithmetic
# jq:   used for JSON
# bash and the GNU coreutils are already in the base image.
RUN apt-get update && \
    apt-get install -y --no-install-recommends bats bc gawk jq && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/test-runner
WORKDIR /opt/test-runner
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

# $ docker build --rm -t exercism/bash-test-runner .
# $ docker run -it --entrypoint bash exercism/bash-test-runner -c 'for i in awk bash bats bc jq; do "$i" --version | head -n1; done'
# GNU Awk 5.2.1, API 3.2, PMA Avon 8-g1, (GNU MPFR 4.2.2, GNU MP 6.3.0)
# GNU bash, version 5.2.37(1)-release (x86_64-pc-linux-gnu)
# Bats 1.11.1
# bc 1.07.1
# jq-1.7
