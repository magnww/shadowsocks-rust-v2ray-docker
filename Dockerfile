FROM --platform=$TARGETPLATFORM alpine
ARG TARGETPLATFORM
ENV ENTRY=ssserver
WORKDIR /ss
COPY $TARGETPLATFORM .
COPY entrypoint.sh .
ENTRYPOINT [ "./entrypoint.sh" ]