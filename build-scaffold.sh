#! /bin/sh
# Author: Dario Meloni <mellon85@gmail.com>
# License: GPLv3 or newer

cd rtorrent-wrb
ruby script/generate scaffold Torrent name:string size:integer upped:integer downloaded:integer up_rate:integer down_rate:integer hash:string status:integer

ruby script/generate scaffold Filelist hash:string name:string size:integer downloaded:integer

ruby script/generate scaffold Trackers hash:string url:string
