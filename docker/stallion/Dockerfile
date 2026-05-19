FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates xz-utils git build-essential libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install ponyup. The init script exits non-zero on the trailing
# "ponyup" usage print even after a successful install, so we tolerate
# the exit code and verify the binary landed.
RUN curl --proto '=https' --tlsv1.2 -sSf \
      https://raw.githubusercontent.com/ponylang/ponyup/latest-release/ponyup-init.sh \
      | sh ; \
    test -x /root/.local/share/ponyup/bin/ponyup

ENV PATH="/root/.local/share/ponyup/bin:${PATH}"

RUN ponyup default x86_64-linux-ubuntu24.04 \
    && ponyup update ponyc release \
    && ponyup update corral release

WORKDIR /app

COPY corral.json ./
RUN corral fetch

COPY main.pony ./
RUN corral run -- ponyc -D openssl_3.0.x

# Runtime image — slim ubuntu plus pony-binary runtime deps.
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
      libssl3 libatomic1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/app /usr/local/bin/

EXPOSE 80
CMD ["/usr/local/bin/app"]
