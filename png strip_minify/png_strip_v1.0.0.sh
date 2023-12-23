#!/bin/bash

<< 'MULTILINE-COMMENT'

Script to remove meta information from png files & minify to suite web sites.
version : v1.0.0
dependencies: exiftool , pngquant
Links:  https://exiftool.org/ , https://github.com/kornelski/pngquant

Input parms:

    # image file.
    eg: ../test_data/image_with_metainfo.png

MULTILINE-COMMENT

extract_metainfo() {
    exiftool -all= $1
}

compress() {
    pngquant --quality=65-80 $1 --ext _min.png
}

if [[ -z $1 ]]; then
    echo missing the file name
    exit 1
fi

if ! command -v exiftool &>/dev/null; then
    echo "exiftool could not be found, please install it first."
    exit
fi

if ! command -v exiftool &>/dev/null; then
    echo "pngquant could not be found, please install it first."
    exit
fi

extract_metainfo $1
compress $1