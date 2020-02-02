#!/bin/sh

tmp="$0"
dir_macos=`dirname "$tmp"`
dir_contents=`dirname "$dir_macos"`
dir_resources="$dir_contents"/Resources

cd $dir_resources
./main
