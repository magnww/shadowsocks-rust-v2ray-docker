FROM --platform=$TARGETPLATFORM alpine
ARG TARGETPLATFORM
ENV ENTRY=ssservice
RUN apk add --no-cache vnstat
WORKDIR /ss
VOLUME /data
COPY $TARGETPLATFORM entrypoint.sh vnstat.conf vnstat_dark.conf ./
EXPOSE 8080
ENTRYPOINT [ "./entrypoint.sh" ]