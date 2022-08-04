#!/bin/bash

<< 'MULTILINE-COMMENT'

Script to download video from youtube and convert to mp3.
version : v1.0.0
dependencies:  youtube-dl 2021.12.17 + , python version 2.6, 2.7, or 3.2+ 
Links:  https://ytdl-org.github.io/youtube-dl/download.html

Input parms:

    # youtube video url.
    eg: https://www.youtube.com/watch?v=AlnJHVa5D-w

MULTILINE-COMMENT

extract_audio_save() {
    /usr/local/bin/youtube-dl --extract-audio --audio-format mp3 $1
}


if [[ -z $1 ]]; then
    echo missing the youtube URL
    exit 1
fi

if ! command -v youtube-dl &>/dev/null; then
    echo "youtube-dl could not be found, please install it first."
    exit
fi

extract_audio_save $1
