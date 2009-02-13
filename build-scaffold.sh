#! /bin/sh
# Author: Dario Meloni <mellon85@gmail.com>
# License: GPLv3 or newer

cd rtorrent-wrb
ruby script/generate scaffold Torrent name:string size:int upped:int downloaded:int up_rate:int down_rate:int ID:string status:int

ruby script/generate scaffold Filelist ID:string name:string size:int downloaded:int

ruby script/generate scaffold Trackers ID:string url:string
