#!/bin/sh
if [ -f ./ss.conf ]; then
  ./$ENTRY -c ./ss.conf &
else
  ./$ENTRY $@ &
fi

if [ -f ./udp2raw.conf ]; then
  ./udp2raw --conf-file udp2raw.conf &
fi

wait -n
exit $?
