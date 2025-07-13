#!/bin/bash

# Quick and dirty way to periodically check public telegram channel's preview URL 
# and throw a notification on new posts.
#
# Can send desktop notifications via libnotify
# and perform text-to-speech conversion via python3-gssapi and ffmpeg.
#
# No telegram account or api_id required.

function tchelp {
	echo "Usage: tgchecker [OPTIONS] https://t.me/s/channel_name"
	echo "Options:"
	echo "	-t --timeout <sec>		Timeout between checks, seconds [default: 30]"
	echo "	-n --notify			Throw desktop notification"
	echo "	-v --voice			Perform text-to-speech conversion and play"
	echo "	-l --lang <lang>		IETF language tag. Language to speak in. [default: en]"
	echo "	-i --intro <text>		Append text to be narrated before notification"
	echo "	-h --help			Show this help"
	exit 1
}


OPTIONS=$(getopt -o ht:nvl:i: --long help,timeout,notify,voice,lang:,intro -- "$@")

eval set -- $OPTIONS

while true; do
	case "$1" in
		-h|--help) HELP=1 ;;
		-t|--timeout) TIMEOUT="$2" ; shift ;;
		-n|--notify) NOTIFY=1 ;;
		-v|--voice) VOICE=1 ;;
		-l|--lang) TCLANG="$2" ; shift ;;
		-i|--intro) INTRO="$2" ; shift ;;
		--)        shift ; break ;;
		*)         echo "unknown option: $1" ; exit 1 ;;
	esac
	shift
done

if [ ! "$1" ] || [ $HELP ]; then
	tchelp
fi

if [ ! "$TIMEOUT" ]; then
	TIMEOUT=30
fi

if [ ! "$TCLANG" ]; then
	TCLANG="en"
fi

if [ ! "$INTRO" ]; then
	INTRO=""
fi

name=$(echo $1 | sed -e 's/^.*\///g')

file_mp3="/tmp/tgchecker_$name.mp3"
file_txt="/tmp/tgchecker_$name.txt"

if ! test -e $file_txt; then
	touch $file_txt
fi

old=$(cat $file_txt)

while true; do

	new=$(curl -s $1 | 
			grep 'tgme_widget_message_text' | 
			tail -n 5 | 
			sed -e 's/<[^>]*>/ /g' -e 's/  */ /g' -e 's/^ //g' -e 's/@.*//g' -e 's/&#33;/!/g')

	diff=$(diff -U0 <(echo "$old") <(echo "$new") | grep ^+ | grep -v ^+++ | sed -e s/.//)

	if [ ! -z "$new" ]; then
		old=$new;
		echo "$old" > $file_txt
	fi

	if [ ! -z "$diff" ]; then
		echo "$diff"

		if [ $NOTIFY ] && \
			command -v notify-send >/dev/null 2>&1; 
		then
			notify-send -a "tgchecker" "$INTRO " "$diff"
		fi

		if [ $VOICE ] && \
			command -v gtts-cli >/dev/null 2>&1 && \
			command -v ffplay >/dev/null 2>&1;
		then
			gtts-cli -l $TCLANG "$INTRO $diff" -o $file_mp3
			ffplay $file_mp3 -nodisp -autoexit >/dev/null 2>&1 &
		fi
	fi

	sleep "$TIMEOUT"s
done
