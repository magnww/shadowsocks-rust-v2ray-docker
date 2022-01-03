#!/bin/sh
if [ -f ./ss.conf ]; then
  ./$ENTRY -c ./ss.conf &
else
  ./$ENTRY $@ &
fi

if [ -f ./udp2raw.conf ]; then
  ./udp2raw --conf-file udp2raw.conf &
fi

if [ -f ./udpspeeder.conf ]; then
  xargs -a udpspeeder.conf ./speederv2 &
fi

mkdir -p /data/vnstat
vnstatd -n --config ./vnstat.conf &
./vnstat_web -config /ss/vnstat.conf -config-dark /ss/vnstat_dark.conf &

wait -n
exit $?
