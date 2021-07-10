#!/bin/bash

version=`git ls-remote --tags --sort -refname https://github.com/my-devices/gateway.git | grep -v '\^{}' | head -1 | awk '{ print $2 }' | sed 's#refs/tags/##'`
if [[ "$version" =~ ^v[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
	echo $version
else
	echo unknown
fi
