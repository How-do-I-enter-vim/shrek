#!/bin/bash

#### the knight who says Ni! and sends shrek to any ssh user

found_hosts=()
found_users=()
found_sessions=()

avoid_list=(vertensj besicb)
target_list=()

target_all=false
just_list=false
help_str="usage:\n./shrek.sh --all\n./shrek.sh --all --avoid user1 user2\n./shrek.sh --target besicb emeka\n"

function send_shrek
{
    cat shrekimage | ssh $1 write $2 $3
    echo "sending shrek to $1 $2 $3"
}
function find_ssh_sessions
{
    local session_count
    who_output=$(ssh $1 who)
    session_count=$(echo "$who_output"| wc -l)
    echo "found $session_count sessions"
    for (( i=1; i<=$session_count; i++ ))
    do
        local line=$(echo "$who_output"|awk -v row=$i 'NR==row')
        local user=$(echo $line|awk '{print $1}')
        local pts=$(echo $line|awk '{print $2}')
        found_hosts=("${found_hosts[@]}" "$1")
        found_users=("${found_users[@]}" "$user")
        found_sessions=("${found_sessions[@]}" "$pts" )
    done
}

hosts=(pearl1 pearl2 pearl3 pearl4 pearl5 pearl6 pearl7 pearl8 pearl9 pearl10)
host_count=${#hosts[*]}
echo "hosts to receive shrek $host_count"

if [ $# == 0 ]; then
    printf "$help_str"
    exit
fi

# 0 = not parsing, 1 = parsing bans, 2 = parsing targets
state=0

for arg in "$@"
do
    if [ "$arg" == "--help" ]; then
        printf "$help_str"
        exit
        #TODO target hosts
    elif [ "$arg" == "--list" ]; then
        just_list=true
        break
    elif [ "$arg" == "--all" ]; then
        target_all=true
    elif [ "$arg" == "--avoid" ]; then
        state=1
    elif [ "$arg" == "--target" ]; then
        state=2
    else
        if [ $state == 0 ]; then
            printf "$help_str"
            exit
        elif [ $state == 1 ]; then
            avoid_list=("${avoid_list[@]}" "$arg")
        elif [ $state == 2 ]; then
            target_list=("${target_list[@]}" "$arg")
        fi
    fi
done

# send_shrek pearl8 "bahadorm" "pts/22"

for (( j=0; j<$host_count; j++ ))
do
    echo "scanning ${hosts[$j]}"
    find_ssh_sessions ${hosts[$j]}
done
target_count=${#found_sessions[*]}
echo "found $target_count in total"

printf "%-15s %-15s %-15s\n" "host" "user" "session"
for (( k=0; k<$target_count; k++ ))
do
    if $target_all ; then
        send=true
        for (( z=0; z<${#avoid_list[*]}; z++ ))
        do
            if [ "${found_users[$k]}" == ${avoid_list[$z]} ]; then
                send=false
            fi
        done
        if $send ; then
            send_shrek ${found_hosts[$k]} ${found_users[$k]} ${found_sessions[$k]}
        fi
    elif $just_list ; then
        printf "%-15s %-15s %-15s\n" "${found_hosts[$k]}" "${found_users[$k]}" "${found_sessions[$k]}"
    else
        for (( z=0; z<${#target_list[*]}; z++ ))
        do
            if [ "${found_users[$k]}" == ${target_list[$z]} ]; then
                send_shrek ${found_hosts[$k]} ${found_users[$k]} ${found_sessions[$k]}
            fi
        done
    fi
done
#find_ssh_sessions pearl7

# ls -l | awk '{print $3}'
# ls -l | awk 'NR==2'