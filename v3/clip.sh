#!/bin/bash

<< 'MULTILINE-COMMENT'

Script to copy file content to clipboard and remove after 10 sec.
version : v1.1.0
dependencies:  xclip
Links:  https://github.com/astrand/xclip

Input parms:

    # text file to be copied
    eg: test/secret.txt

MULTILINE-COMMENT

copy_and_distroy() {

	xclip -rmlastnl -selection clipboard -i $1

	#sleep 10s

	touch /tmp/t

	bash -c 'sleep 10s; xclip -selection clipboard -i /tmp/t' &

}

if [[ -z $1 ]]; then
	echo missing the file name
	exit 1
fi

if ! command -v xclip &>/dev/null; then
	echo "xclip could not be found, please install it first."
	exit
fi

copy_and_distroy $@
