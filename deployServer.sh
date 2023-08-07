#!/bin/bash

echo "start run bulid command"
npm run build

echo "ready to publish to 101.35.171.230"

if [[ "$1" == "-rsync" ]];
then
    echo "start using rsync synchronization"
    rsync -rv dist root@101.35.171.230:/www/dev/gifft-me-mobile
else
    echo "start using scp synchronization"
    scp -r dist root@101.35.171.230:/www/dev/gifft-me-mobile
fi