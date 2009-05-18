require 'rubygems'
require 'SCGIxml'
require 'pp'

SOCKET="/tmp/rtorrent.sock"

rtorrent = SCGIXMLClient.new([SOCKET,"/RPC2"])
puts rtorrent.call("system.listMethods")

torrents = []
torrents = rtorrent.call("d.multicall","","d.get_base_path=")
pp torrents
