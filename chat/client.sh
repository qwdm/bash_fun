#!/bin/bash

PORT=3001
HOST=localhost

if [ $# -ne 1 ]; then
    echo "Usage: $0 <USERNAME>"
    exit 1
fi
NAME=$1

new_port=$(echo "HELLO" | nc $HOST $PORT -q 1)
echo "new port: $new_port" >&2

fifo_dir=$(mktemp -d)
#echo "fifo dir: $fifo_dir" >&2

incoming="${fifo_dir}/incoming"
outgoing="${fifo_dir}/outgoing"
#echo "incoming: $incoming" >&2
#echo "fifo dir: $outgoing" >&2

mkfifo $incoming
mkfifo $outgoing

exec 3<> $incoming
exec 4<> $outgoing

nc $HOST $new_port <&4 >&3 &

cat $incoming | grep -v "^$1:" &

while read line; do
    echo "$1: $line" >$outgoing
done
