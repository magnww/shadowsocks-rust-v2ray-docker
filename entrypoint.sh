#!/bin/sh
trap 'exit 0' SIGTERM

SS_ARGS="$@"
if [ -f ./ss.conf ]; then
  ./$ENTRY server -c ./ss.conf &
elif [ $ENTRY = ssservice ]; then
  if [ ${SS_ARGS:0:5} = "local" -o ${SS_ARGS:0:6} = "server" -o ${SS_ARGS:0:7} = "manager" ]; then
    ./$ENTRY $SS_ARGS &
  else
    ./$ENTRY server $SS_ARGS &
  fi
else
  ./$ENTRY $SS_ARGS &
fi

if [ -f ./udp2raw.conf ]; then
  ./udp2raw --conf-file udp2raw.conf &
fi

if [ -f ./udp2raw2.conf ]; then
  ./udp2raw --conf-file udp2raw2.conf &
fi

if [ -f ./udpspeeder.conf ]; then
  xargs -a udpspeeder.conf ./speederv2 &
fi

if [ -f ./kcptun_server.conf ]; then
  ./kcptun_server -c ./kcptun_server.conf &
fi

if [ -f ./kcptun_client.conf ]; then
  ./kcptun_client -c ./kcptun_client.conf &
fi

if [ -f ./chisel.conf ]; then
  xargs -a chisel.conf ./chisel &
fi

mkdir -p /data/vnstat
vnstatd -n --config ./vnstat.conf &
./vnstat_web -config /ss/vnstat.conf -config-dark /ss/vnstat_dark.conf &

wait -n
exit $?
