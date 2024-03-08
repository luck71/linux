#!/bin/bash

SCRIPT_REL_PATH=$(dirname "$0")
export SCRIPT_ABS_PATH=$(realpath ${SCRIPT_REL_PATH})

terminal=$(ps -p $$ | awk 'NR==2{print $2}')
exec 1>/dev/${terminal}
# export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
echo "" 
echo "执行 ./${SCRIPT_REL_PATH}/printstage.sh" 
echo ""
#env
#pstree -a -s -p $$
#lsof  -p $$
#pid=$(pstree -s -p $$ | grep -o 'python3.9(\([0-9]\+\))' | grep -o '(\([0-9]\+\)' | grep -o '[0-9]\+')
#echo $pid
#lsof -p ${pid}
#sudo cat /proc/${pid}/environ

exec 1>&-

exit 0
