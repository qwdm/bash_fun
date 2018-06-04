#!/usr/bin/env bash

# echoes everything PROCESSED back
# architecture schema:
#   nc -> incoming_messages_fifo -> line processor -> outgoing_messages_fifo -> nc

# examples of processor:
#./echo_processed.sh 3000 "sed 's/a/b/g'"
#./echo_processed.sh 3000 "tr 'a-z' 'A-Z'"
#./echo_processed.sh 3000 "python -u -c 'print raw_input().upper()'"


if [ $# -ne 2 ]
then
    echo "Usage: $0 <port> <process_cmd>"
    exit 1
fi

port=$1
process=$2

fifo_dir=$(mktemp -d)
incoming=${fifo_dir}/incoming
outgoing=${fifo_dir}/outgoing
mkfifo ${incoming}
mkfifo ${outgoing}

echo $incoming $outgoing

# open fifos for reading and writing
exec 3<> ${incoming}  
exec 4<> ${outgoing}

echo "start listening, verbose mode, allow new (k)onnections"
nc -vkl $port >&3 <&4 &

cat $incoming | while read line; do
    echo $line | eval "$process"
done > $outgoing
