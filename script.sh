#!/bin/bash

directory="test"
for file in "$directory"/*
do
    if [ -f "$file" ]; then
        sed -i "s/*/!/g" "$file"
        echo "Replaced occurrences in file: $file"
    fi
done
