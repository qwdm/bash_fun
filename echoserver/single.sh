#!/usr/bin/env bash

# single connection server
# works till client send something
# echoes everything back

if [ $# -ne 1 ]
then
    echo "Usage: $0 <port>"
    exit 1
fi

port=$1

fifo=$(mktemp -d)/fifo
mknod ${fifo} p

exec 3<> ${fifo}  # open fifo for reading and writing

echo "start listening"
nc -l $port <&3 >&3
