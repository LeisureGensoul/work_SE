FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 可选：换镜像源（不传就用默认）
ARG UBUNTU_MIRROR=http://archive.ubuntu.com/ubuntu
ARG UBUNTU_SECURITY_MIRROR=http://security.ubuntu.com/ubuntu

# 让 apt 更抗抖（重试/超时/fix-missing）
RUN set -eux; \
    sed -i "s|http://archive.ubuntu.com/ubuntu|${UBUNTU_MIRROR}|g" /etc/apt/sources.list; \
    sed -i "s|http://security.ubuntu.com/ubuntu|${UBUNTU_SECURITY_MIRROR}|g" /etc/apt/sources.list; \
    printf 'Acquire::Retries "5";\nAcquire::http::Timeout "30";\nAcquire::https::Timeout "30";\nAPT::Get::Fix-Missing "true";\n' \
      > /etc/apt/apt.conf.d/80-retries

# 基础开发依赖
RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      ca-certificates \
      curl \
      wget \
      openssh-client \
      cmake \
      pkg-config \
      python3 \
      python3-pip; \
    rm -rf /var/lib/apt/lists/*

# git global 信息
RUN set -eux; \
    git config --global user.name "Gensoul"; \
    git config --global user.email "gensoul030929@outlook.com"

# clone 主仓库并递归拉子模块
WORKDIR /root
RUN set -eux; \
    git clone https://github.com/LeisureGensoul/work_SE.git; \
    cd work_SE; \
    git submodule update --init

# 安装 node/npm + codex（更稳：再加一次 update；apt 已配置重试）
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs npm; \
    npm i -g @openai/codex; \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

# 1. docker build -t work_se-dev .
# 2. docker build -t work_se-dev --build-arg UBUNTU_MIRROR=http://azure.archive.ubuntu.com/ubuntu --build-arg UBUNTU_SECURITY_MIRROR=http://security.ubuntu.com/ubuntu .

# 3. docker container run --name work_SE -it work_se-dev bash