#!/bin/bash

if [[ ! -e $1 ]]; then
    mkdir $1
elif [[ ! -d $1 ]]; then
    echo "$1 already exists but is not a directory" 1>&2
fi

