FROM --platform=$TARGETPLATFORM alpine AS builder
RUN apk add --no-cache build-base libnsl-dev && \
    wget http://www.cs.columbia.edu/~lennox/udptunnel/udptunnel-1.1.tar.gz && \
    tar -zxvf udptunnel-1.1.tar.gz && \
    cd udptunnel-1.1/ && \
    ./configure && \
    make

FROM --platform=$TARGETPLATFORM alpine
ARG TARGETPLATFORM
ENV ENTRY=ssservice
RUN apk add --no-cache vnstat wireguard-tools
WORKDIR /ss
VOLUME /data
COPY $TARGETPLATFORM entrypoint.sh vnstat.conf vnstat_dark.conf ./
COPY --from=builder /udptunnel-1.1/udptunnel ./
EXPOSE 8080
ENTRYPOINT [ "./entrypoint.sh" ]