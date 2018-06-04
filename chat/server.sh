#!/usr/bin/env bash

PORT=3001

I=3

# one can use mktemp, but it is convenient to have time ordering for debug
FIFO_DIR="/tmp/chat.$(date +%s)"
mkdir -p $FIFO_DIR || exit 1
echo "FIFO_DIR: $FIFO_DIR"

client_response_fifos=$FIFO_DIR/crf_list
client_port=$(( PORT + 1 ))

log () {
    echo $1 >&2
}

make_fifo () {
    local fname
    fname=${FIFO_DIR}/$1
    mkfifo $fname
    echo $fname
}

CLIENT_REQUEST_FIFO=$(make_fifo client_request_fifo)
echo "Client Request Fifo $CLIENT_REQUEST_FIFO"

process_client () {
    local new_response_fifo
    new_response_fifo=$(make_fifo client_${client_port})
#    client_response_fifos=( ${client_response_fifos[*]} $new_response_fifo )
    echo $new_response_fifo >> $client_response_fifos
    log "NOW CLIENTS: ${client_response_fifos[*]}"
#    exec $(( I++ ))<> ${new_response_fifo}
    sleep 60000 > ${new_response_fifo} &  # keep open
    cat $new_response_fifo | nc -vkl ${client_port} >${CLIENT_REQUEST_FIFO} &
#    cat $new_response_fifo 3>$new_response_fifo | nc -vkl ${client_port} >${CLIENT_REQUEST_FIFO} &
#    nc -vkl ${client_port} >${CLIENT_REQUEST_FIFO} <&${I} &
#    nc -vkl ${client_port} >${CLIENT_REQUEST_FIFO} <${new_response_fifo} & #; echo "Stopped $client_port" >&2 &
    log "Start client service on $client_port port"
    echo $client_port
    (( client_port++ ))
}

message_broker () {
    cat $CLIENT_REQUEST_FIFO | while read line; do
        log "oops!: $line"
        log "Clients: $(cat $client_response_fifos)"
        for client_fifo in $(cat ${client_response_fifos}); do
            log "$line to $client_fifo"
            echo $line > $client_fifo
        done
    done
}


echo "Start Message Broker"
message_broker &

fifo_request=$(make_fifo fifo_request)
fifo_response=$(make_fifo fifo_response)

nc -v -k -l $PORT >${fifo_request} <${fifo_response} || exit 1 &

echo "Listening on $PORT"

cat $fifo_request | while read line;
do
    process_client $line
#    echo $line | sed 's/a/b/g' 
done > $fifo_response


#cat $fifo_request | python -u -c 'while 1: print raw_input().upper()' > $fifo_response
