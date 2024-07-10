#!/bin/bash
while IFS='=' read -r key value; do
    if [[ $key != '#'* ]]; then
        echo "$key=\"$value\""
    fi
done < "$1"
