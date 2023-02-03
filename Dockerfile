FROM --platform=$TARGETPLATFORM alpine AS builder
RUN apk add --no-cache build-base git && \
    git clone https://github.com/rfc1036/udptunnel.git && \
    cd udptunnel/ && \
    make

FROM --platform=$TARGETPLATFORM alpine
ARG TARGETPLATFORM
ENV ENTRY=ssservice
RUN apk add --no-cache vnstat wireguard-tools
WORKDIR /ss
VOLUME /data
COPY $TARGETPLATFORM entrypoint.sh vnstat.conf vnstat_dark.conf ./
COPY --from=builder /udptunnel/udptunnel ./
EXPOSE 8080
ENTRYPOINT [ "./entrypoint.sh" ]