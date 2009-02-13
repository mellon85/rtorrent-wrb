#! /bin/sh
# License: GPLv3 or newer

ruby script/generate scaffold Torrent name:string size:integer upped:integer downloaded:integer up_rate:integer down_rate:integer torrent_hash:string status:integer

ruby script/generate scaffold Filelist torrent_hash:string name:string size:integer downloaded:integer

ruby script/generate scaffold Trackers torrent_hash:string url:string
