#!/bin/bash

# polish notation calc

# (+ 1 2) -> 3
# (* 7 3) -> 21
# (+ (* 2 3) 5) -> 30

source utils.sh

__plus__ () {
    reduce _sum2 0 $*
}

__mult__ () {
    reduce _mul2 1 $*
}

__minus__ () {
    local IFS='-'
    exprs=$(echo "$*")
    echo "$(( $exprs ))"
}

__div__ () {
    if [[ "$#" -eq 2 ]]; then
        echo "$(( $1 / $2 ))" 
    else
        echo >&2 "division should have 2 args"
        exit 1
    fi
}

__mod__ () {
    if [[ "$#" -eq 2 ]]; then
        echo "$(( $1 % $2 ))" 
    else
        echo >&2 "modulo should have 2 args"
        exit 1
    fi
}

typeset -A builtin_functions

kwset builtin_functions \
'+' '__plus__' \
'-' '__minus__' \
'/' '__div__' \
'%' '__mod__' \
'*' '__mult__' \

tokenize () {
    sed 's/(\|)/ & /g; s/\s\s*/\n/g' | grep -v "^$"
}

evaluate () {
    local func
    local token
    local args=( )

    read action

    if [[ -n ${builtin_functions["$action"]} ]]; then
        func=${builtin_functions["$action"]}
    fi 

    while read token; do
        case "$token" in
            ')')
                echo "$($func ${args[*]})"
                return 0
                ;;
            '(')
                args=( "${args[@]}" `evaluate` )
                ;;
            *)
                args=( "${args[@]}" "$token" )
        esac
    done
}

tokenize | tail -n+2 | evaluate
