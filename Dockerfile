FROM ubuntu:latest as build

RUN sed -i \
        -e 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' \
        -e 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' \
        /etc/apt/sources.list && \
    apt update

RUN apt install -y git build-essential wget curl apt-transport-https curl gnupg zip

# Bazelisk
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.16.0/bazelisk-linux-amd64 \
        -O /usr/bin/bazelisk && chmod a+x /usr/bin/bazelisk
        

RUN git clone https://gerrit.googlesource.com/gitiles --depth 1 /src
WORKDIR /src
RUN git submodule update -r --init

# 编译
RUN bazelisk build //:gitiles

FROM jetty:9.4.51-jre8-alpine

COPY --from=build /src/bazel-bin /app

WORKDIR /app

RUN $JETTY_HOME/start.jar --add-to-startd=http2 --approve-all-license  gitiles.war