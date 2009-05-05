require 'rubygems'
require 'SCGIxml'

SOCKET="/tmp/rtorrent.sock"

rtorrent = SCGIXMLClient.new([SOCKET,"/RPC2"])
puts rtorrent.call("system.listMethods")

rtorrent.call("download_list","main").each do |x|
    puts rtorrent.call("p.multicall",x,"","p.get_address=","p.get_down_rate=")
end
