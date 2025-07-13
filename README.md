# telegram-checker

Quick and dirty way to periodically check public telegram channel's preview URL and throw notifications on new posts.

Can send desktop notifications via libnotify and perform text-to-speech conversion via python3-gssapi and ffmpeg.

No telegram account or api_id required.

## Dependencies
- curl
- libnotify (optional, for desktop notifications)
- python3-gtts, ffmpeg (optional, for text-to-speech conversion)

## Installation (example for deb-based distro)
Install the dependencies, if needed:
```
$ sudo apt install curl libnotify python3-gssapi ffmpeg
```
Make the **.local/bin** directory if not exists (optional, just for launching the script without specifying full path) 
```
mkdir ~/.local/bin
```
Download the script and make it executable
```
cd ~/.local/bin
wget https://raw.githubusercontent.com/noisedsn/telegram-checker/refs/heads/main/tgchecker.sh
chmod u+x tgchecker.sh
```

## Usage
```
Usage: tgchecker [OPTIONS] https://t.me/s/channel_name
Options:
  -t --timeout <sec>		Timeout between checks, seconds [default: 30]
	-n --notify			Throw desktop notification
	-v --voice			Perform text-to-speech conversion and play
	-l --lang <lang>		IETF language tag. Language to speak in. [default: en]
	-i --intro <text>		Append text to be narrated before notification
	-h --help			Show this help
```
