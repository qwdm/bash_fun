#!/bin/bash


#####################################
#### consts & vars declarations #####
#####################################

HEIGHT=20
WIDTH=40

DELAY=5  # centiseconds

SNAKE_SYMBOL='0'
BOARD_SYMBOL='#'
RABBIT_SYMBOL='*'
SPACE_PROXY_SYMBOL='_'  # work around space args issue

declare -a scr

declare -a snake
SHRINKING_RATE=3
INIT_LENGTH=7
direction='RIGHT'
declare -i shrinking=0

rabbit=0


############################
#### procedures & funcs ####
############################

join () {
    local IFS="$1" 
    shift 
    echo "$*" 
}

zbseq () {
    seq 0 $(( ${1} - 1 ))
}

scr_boards () {

    # boards
    for i in `zbseq $WIDTH`; do
        scr[${i}]="$BOARD_SYMBOL"
        scr[$(( $i + $WIDTH * ($HEIGHT-1) ))]="$BOARD_SYMBOL"
    done

    for i in `zbseq $HEIGHT`; do
        scr[$(( $i * $WIDTH ))]="$BOARD_SYMBOL"
        scr[$(( $i * $WIDTH + $WIDTH - 1 ))]="$BOARD_SYMBOL"
    done
}

scr_init () {
    
    for i in `zbseq $HEIGHT`; do
        for j in `zbseq $WIDTH`; do
            scr[$(( $i * $WIDTH + $j))]=$SPACE_PROXY_SYMBOL
        done
    done

    scr_boards
}

scr_print () {
    local s=""
    for i in `zbseq $HEIGHT`; do
        s+="$(echo "${scr[*]:$(( i * WIDTH )):$WIDTH}" | sed 's/ //g')\n"
    done
    s=$( printf "$s" | sed "s/$SPACE_PROXY_SYMBOL/ /g" )
    clear
    printf "$s\n" 
}

key_read () {
    local key=''
    local tmpkey=''

    # this for guaranteed time of delay
    for _ in `seq $DELAY`; do
        read -s -n3 -t .01 tmpkey
        if [[ -n $tmpkey && $tmpkey != $key ]]; then
            key=$tmpkey
        fi
    done

    # little trick
    case ${key:2} in
        A) key=UP ;;
        B) key=DOWN ;;
        D) key=LEFT ;;
        C) key=RIGHT ;;
        'qqq')  key=QUIT ;;
        *)    key='';;
    esac

    echo $key
}

snake_init () {
    local center=$(( $WIDTH/2 * $HEIGHT + $WIDTH/2))
    snake=( `seq $(( center - INIT_LENGTH + 1)) $(( center ))` )
}

snake_to_scr () {
    for i in ${snake[*]}; do
        scr[$i]="$SNAKE_SYMBOL"
    done
}

snake_get_new_head () {
    local direction=$1 
    local new_head
    local head=${snake[-1]}

    case $direction in 
        'RIGHT') new_head=$(( head + 1 ))      ;;
        'LEFT')  new_head=$(( head - 1 ))      ;;
        'UP')    new_head=$(( head - WIDTH )) ;;
        'DOWN')  new_head=$(( head + WIDTH )) ;;
    esac
    
    echo $new_head
}
    
snake_update () {
    local new_head=$1
    local tail_factor

    case ${scr[$new_head]} in
        "$RABBIT_SYMBOL")
            shrinking=$(( $shrinking + $SHRINKING_RATE ))
            rabbit_update
            ;;
        "$BOARD_SYMBOL"|"$SNAKE_SYMBOL")
            game_over
            ;;
    esac

    tail_factor=$([[ $shrinking -ne 0 ]] && echo 0 || echo 1)
    snake=( ${snake[*]:$tail_factor} $new_head )

    shrinking=$([[ $shrinking -gt 0 ]] && echo $(( $shrinking - 1 )) || echo $shrinking )
}

rabbit_update () {
    rabbit=0
    until [[ ${scr[$rabbit]} -eq $SPACE_PROXY_SYMBOL ]]
    do
        rabbit=$(( RANDOM % ( HEIGHT * WIDTH ) ))
    done 
}

rabbit_to_scr () {
    if [[ "$rabbit" -eq "0" ]]; then
        rabbit_update
    fi
    scr[$rabbit]=$RABBIT_SYMBOL
}



get_direction () {
    local direction=$1
    local key=$2

    if [[ -n "$key" ]]
    then
        echo $key
    else
        echo $direction
    fi
}

info_to_scr () {
    # not implemented
    echo -n >/dev/null
}

game_over () {
    echo "Your LENGTH is ${#snake[*]}" 
    echo "GAME OVER"
    exit
}
    
        
    
#######################
####### main ##########
#######################

        
snake_init

while true; do
    scr_init

    snake_to_scr
    rabbit_to_scr  # update on first iteration
#    info_to_scr

    scr_print    

    key=$(key_read)
    direction=$(get_direction $direction $key)
    new_head=$(snake_get_new_head $direction)

    snake_update $new_head
done
