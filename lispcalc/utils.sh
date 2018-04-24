
kwset () {
    local a=$1
    shift

    while (( "$#" )); do
        eval "$a['$1']='$2'"
        shift
        shift
    done
}

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
