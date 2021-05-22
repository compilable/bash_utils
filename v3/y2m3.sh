#!/bin/bash
# v.1.0 : download video from youtube and convert to mp3.
# utility software = youtube-dl : https://github.com/ytdl-org/youtube-dl/

extract_audio_save() {
    /usr/local/bin/./youtube-dl --extract-audio --audio-format mp3 $1
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