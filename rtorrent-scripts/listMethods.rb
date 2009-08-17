require 'rubygems'
require 'SCGIxml'
require 'pp'

SOCKET="/tmp/rtorrent.sock"

rtorrent = SCGIXMLClient.new([SOCKET,"/RPC2"])
puts rtorrent.call("system.listMethods")
puts rtorrent.call("get_down_rate")
puts rtorrent.call("get_down_total")

#pp rtorrent.call("d.multicall","","d.get_base_path=")
#pp rtorrent.call("f.multicall","BD96AA4C228655083AEB3A9E7FC290EBFAC33226","","f.get_path_components=")
