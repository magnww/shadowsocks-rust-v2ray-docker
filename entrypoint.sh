#!/bin/sh
if [ -f ./ss.conf ]; then
  ./$ENTRY -c ./ss.conf "$@"
else
  ./$ENTRY "$@"
fi