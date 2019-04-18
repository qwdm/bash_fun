#### bash useful utils & functions ####

venv () {
    local path
    
    cwd="."
    for i in `seq 3`; do
        for path in $(find "$cwd"  -maxdepth 3 -name activate); do
            if grep -e "^VIRTUAL_ENV=" $path; then  # could be -q, but it is convenient to see
                source $path
                return 0
            fi
        done
        cwd="$cwd/.."
    done
    return 1
}

optopt () {
    local option
    local value
    option=$1
    value=$2

    [ -n "$value" ] && echo "$option $value"
}

cl () {
    local col_num
    local sep
    col_num=$1
    sep=$2

    local USAGE="USAGE: cl col_num [sep]"

    if [ -z "$col_num" ];
    then
        echo $USAGE >&2
        return 1
    fi 
    
    sep_option=$( [ -n "$sep" ] && echo "-F $sep" )

    awk $sep_option "{print \$$col_num}"
}

halfhour () {
    date

    for i in `seq 30`; do
        sleep 60
        echo -n "$i "
    done

    for i in `seq 5`; do
        notify-send "Wake Up $i"
    done

}

export -f cl
export -f venv
