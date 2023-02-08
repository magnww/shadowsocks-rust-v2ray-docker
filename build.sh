#!/bin/bash
shopt -s extglob
chmod -R 755 linux
NAMESPACE="lostos"
REPOSITORY="shadowsocks-rust"
DOCKER_REGISTY=$NAMESPACE/$REPOSITORY
TAG_NAME=$(curl -s https://api.github.com/repos/shadowsocks/shadowsocks-rust/tags | grep -E 'name' | cut -d '"' -f 4 | head -n 1)
if [[ $TAG_NAME =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  STABLE=1
fi
echo $TAG_NAME
echo STABLE=$STABLE

if [[ $* != *force* ]]; then
  echo "check update..."
  if [ "200" = "$(curl -s -o /dev/null -w "%{http_code}" https://hub.docker.com/v2/namespaces/$NAMESPACE/repositories/$REPOSITORY/tags/$TAG_NAME)" ]; then
    echo "no update."
    exit
  fi
fi

echo "updateing..."
WORKDIR=$(pwd)

for TARGETPLATFORM in linux/amd64 linux/arm/v7 linux/arm64; do # linux/arm/v7 linux/arm64
  mkdir -p $TARGETPLATFORM
  cd $TARGETPLATFORM
  rm -f !(udp2raw|speederv2|vnstat_web|kcptun_server|kcptun_client|chisel)
  if [ "$TARGETPLATFORM" = "linux/amd64" ]; then
    ARCH_SS=x86_64-unknown-linux-musl
    ARCH_V2RAY=linux-amd64
  elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then
    ARCH_SS=arm-unknown-linux-musl
    ARCH_V2RAY=linux-arm
  elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then
    ARCH_SS=aarch64-unknown-linux-musl
    ARCH_V2RAY=linux-arm64
  fi
  echo $ARCH_SS $ARCH_V2RAY
  curl -s https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/tags/$TAG_NAME |
    grep -E 'browser_download_url' |
    grep $ARCH_SS |
    grep "tar.xz\"$" |
    cut -d '"' -f 4 |
    wget -qi - -qO- |
    tar xJ
  rm -f sslocal ssmanager ssserver ssurl
  curl -s https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest |
    grep -E 'browser_download_url' |
    grep $ARCH_V2RAY |
    cut -d '"' -f 4 |
    wget -qi - -qO- |
    tar xz
  if [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then
    mv v2ray-plugin_linux_arm7 v2ray-plugin
    rm v2ray-plugin_*
  else
    mv v2ray-plugin* v2ray-plugin
  fi
  cd $WORKDIR
done

docker buildx build \
--push \
--platform linux/amd64,linux/arm/v7,linux/arm64 \
--build-arg TAG_NAME=$TAG_NAME \
--tag $DOCKER_REGISTY:latest \
--tag $DOCKER_REGISTY:$TAG_NAME \
${STABLE:+--tag $DOCKER_REGISTY:stable} \
.
