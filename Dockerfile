FROM ubuntu:latest as build

RUN sed -i \
    -e 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' \
    -e 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' \
    /etc/apt/sources.list && \
    apt update

RUN apt install -y git build-essential wget curl apt-transport-https curl gnupg zip openjdk-8-jdk

# Bazelisk
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.16.0/bazelisk-linux-amd64 \
    -O /usr/bin/bazelisk && chmod a+x /usr/bin/bazelisk

# Gitiles branch
ARG GITILES_BARNCH=v1.1.0

# Download sources
RUN git clone https://gerrit.googlesource.com/gitiles /src -b ${GITILES_BARNCH}
WORKDIR /src
RUN git submodule update -r --init

# build
RUN bazelisk build //:gitiles


# runtime
FROM jetty:9.4.51-jre8-alpine

COPY --from=build /src/bazel-bin /app
WORKDIR /app

RUN java -jar ${JETTY_HOME}/start.jar --add-to-startd=http2 --approve-all-license
