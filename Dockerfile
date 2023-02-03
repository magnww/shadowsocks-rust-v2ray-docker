FROM --platform=$TARGETPLATFORM alpine AS builder
RUN apk add --no-cache build-base git && \
    git clone https://github.com/MarkoPaul0/DatagramTunneler.git && \
    cd DatagramTunneler/ && \
    make

FROM --platform=$TARGETPLATFORM alpine
ARG TARGETPLATFORM
ENV ENTRY=ssservice
RUN apk add --no-cache vnstat wireguard-tools libstdc++
WORKDIR /ss
VOLUME /data
COPY $TARGETPLATFORM entrypoint.sh vnstat.conf vnstat_dark.conf ./
COPY --from=builder /DatagramTunneler/bin/datagramtunneler ./
EXPOSE 8080
ENTRYPOINT [ "./entrypoint.sh" ]