#!/bin/bash

if [[ ! -e /home/ubuntu/$1 ]]; then
    mkdir /home/ubuntu/$1
elif [[ ! -d /home/ubuntu/$1 ]]; then
    echo "/home/ubuntu/$1 already exists but is not a directory" 1>&2
fi

