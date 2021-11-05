#!/bin/bash
chmod -R 755 .
TAG_NAME=$(curl -s https://api.github.com/repos/shadowsocks/shadowsocks-rust/tags | grep -E 'name' | cut -d '"' -f 4 | head -n 1)
echo $TAG_NAME

WORKDIR=$(pwd)

for TARGETPLATFORM in linux/amd64; do # linux/arm/v7 linux/arm64
  mkdir -p $TARGETPLATFORM
  cd $TARGETPLATFORM
  rm *
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
  --load \
  --platform linux/amd64 \
  --build-arg TAG_NAME=$TAG_NAME \
  --tag lostos/shadowsocks-rust:latest \
  --tag lostos/shadowsocks-rust:$TAG_NAME \
  .
