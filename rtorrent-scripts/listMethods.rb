require 'rubygems'
require 'SCGIxml'

SOCKET="/tmp/rtorrent.sock"

rtorrent = SCGIXMLClient.new([SOCKET,"/RPC2"])
puts rtorrent.call("system.listMethods")
