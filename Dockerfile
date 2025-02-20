#
# Install from source to include latest patches
#
FROM rust:buster AS base

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes ca-certificates git make && \
  apt-get clean

FROM base AS build

RUN git clone https://github.com/OLSF/libra.git /root/libra

WORKDIR /root/libra

RUN apt-get install -y git vim zip unzip jq build-essential cmake clang llvm libgmp-dev secure-delete pkg-config libssl-dev lld

RUN cargo install toml-cli
RUN cargo install sccache

RUN make bins && make install

FROM base

COPY --from=build /root/bin/* /usr/bin/

#
# Install using official install script in the future
#
# FROM ubuntu:focal
# ENV PATH="${PATH}:~/bin"
# RUN apt-get update && apt-get install -y curl && apt-get clean
# RUN curl -sL https://raw.githubusercontent.com/OLSF/libra/main/ol/util/install.sh | bash

ENV NODE_ENV="prod"

WORKDIR /root/.0L

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD tower -U start
