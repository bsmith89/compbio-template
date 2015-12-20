#!/usr/bin/env bash

file=$(mktemp)
cat <&0 >$file
jupyter nbconvert --to notebook --ClearOutputPreprocessor.enabled=True $file --stdout
