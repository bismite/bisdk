#!/bin/bash

echo " * * * build bilibs"
./scripts/build_bilibs.sh
echo " * * * build mruby"
./scripts/build_mruby.sh
echo " * * * build template"
./scripts/build_template.sh
echo " * * * build release"
./scripts/build_release.sh
