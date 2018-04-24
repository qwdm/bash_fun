

typeset -A cases

kwset () {
    local a=$1
    shift

    while (( "$#" )); do
        eval $a["$1"]="$2"
        shift
        shift
    done
}

mktest () {
    local program="$1"
    local expectation="$2"
    result=$(echo "$program" | bash lispcalc.sh)
    if [[ "$result" -eq "$expectation" ]]; then
        echo "OK"
    else
        echo "$program -> '$result'; but expects '$expectation'"
    fi
}


kwset cases \
'(+ 1 2)' 3 \
'(- 4 1)' 3 \
'(* 4 12)' 48 \
'(+ 3 (* 10 23))' 233 \

#for tst in "${!cases[@]}"; do
#    echo "$tst" "${cases[$tst]}"
#done    

for tst in "${!cases[@]}"; do
    mktest "$tst" "${cases[$tst]}"
done    
