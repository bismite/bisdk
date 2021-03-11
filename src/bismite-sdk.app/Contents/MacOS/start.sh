#!/bin/sh

DIR=$(dirname $0)/../Resources/bin
export PATH="${DIR}:${PATH}"

clear
echo "* bismite-sdk *"
echo "PATH: ${DIR}"
echo "SHELL: ${SHELL}"
echo "----"
$SHELL
