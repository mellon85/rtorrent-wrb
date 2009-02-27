require 'rubygems'
require 'SCGIxml'

SOCKET="/tmp/rtorrent.sock"

rtorrent = SCGIXMLClient.new([SOCKET,"/RPC2"])
puts rtorrent.call("system.listMethods")

puts rtorrent.call("f.get_priority","904674444D7F694240089817E507A8110D341BF5",0)
