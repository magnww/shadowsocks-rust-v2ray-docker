#!/bin/sh
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

if [ -f ./wireguard.conf ]; then
  ip link add dev wg0 type wireguard
  ip addr add 10.19.19.1/24 dev wg0
  ip link set mtu 1280 up dev wg0
  wg setconf wg0 ./wireguard.conf
  iptables -t nat -A POSTROUTING -s 10.19.19.0/24 -o eth0 -j MASQUERADE
  iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
  ./wstunnel -v --server --restrictTo 127.0.0.1:2320 ws://0.0.0.0:2320 &
fi

if [ -f ./wstunnel.conf ]; then
  xargs -a wstunnel.conf ./wstunnel &
fi

mkdir -p /data/vnstat
vnstatd -n --config ./vnstat.conf &
./vnstat_web -config /ss/vnstat.conf -config-dark /ss/vnstat_dark.conf &

wait -n
exit $?
