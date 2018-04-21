#!/bin/bash

# polish notation calc

# (+ 1 2) -> 3
# (* 7 3) -> 21
# (+ (* 2 3) 5) -> 30


# some functional programming stuff
map () {
    local func=$1
    shift

    for arg in $*; do
        echo $( $func $arg)
    done
}

reduce () {
    local func=$1
    local init=$2
    shift; shift

    local res=$init
    for i in $*; do
        res=$( $func res $i )
    done
    
    echo $res
}

_double () {
    echo $(( $1 * 2 ))
}

_sum2 () {
    echo $(( $1 + $2 ))
}

_mul2 () {
    echo $(( $1 * $2 ))
}

_test () {
    local a=( 1 2 3 4 )
    echo "list a: ${a[*]}"

    b=( `map _double ${a[*]}` )
    echo "map double: ${b[*]}"

    b=( `reduce _sum2 0 ${a[*]}` )
    echo "reduce _sum2: ${b[*]}"
}
    

#_test



#################################################

__plus__ () {
    reduce _sum2 0 $*
}

__mult__ () {
    reduce _mul2 1 $*
}

tokenize () {
    sed 's/(\|)/ & /g; s/\s\s*/\n/g' | grep -v "^$"
}

evaluate () {
    local func
    local token
    local args=( )

    read func

    case $func in
        '*')
            func='__mult__'
            ;;
        '+')
            func='__plus__'
            ;;
    esac

    while read token; do
        case $token in
            ')')
                echo $($func ${args[*]})
                return 0
                ;;
            '(')
                args=( ${args[*]} `evaluate` )
                ;;
            *)
                args=( ${args[*]} $token )
        esac
    done
}

tokenize | tail -n+2 | evaluate
