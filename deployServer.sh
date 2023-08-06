#!/bin/bash

if [[ "$1" == "-rsync" ]];
then
    echo "开始使用rsync同步"
    rsync  -rv  ./  root@101.35.171.230:/www/dev/gifft-me
else
    echo "开始使用scp同步"
    scp  -r  ./  root@101.35.171.230:/www/dev/gifft-me
fi