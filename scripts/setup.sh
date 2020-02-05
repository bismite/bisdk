#!/bin/bash

echo " * * * build bilibs"
./scripts/build_bilibs.sh
echo " * * * build mruby"
./scripts/build_mruby.sh
echo " * * * copy license files"
./scripts/licenses.sh
echo " * * * build template"
./scripts/build_template.sh
