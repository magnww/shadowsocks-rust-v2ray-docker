FROM --platform=$TARGETPLATFORM alpine
ARG TARGETPLATFORM
ENV ENTRY=ssserver
WORKDIR /ss
COPY $TARGETPLATFORM .
COPY entrypoint.sh .
RUN apk add --no-cache iptables
ENTRYPOINT [ "./entrypoint.sh" ]