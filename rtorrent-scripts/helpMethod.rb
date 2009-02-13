require 'rubygems'
require 'SCGIxml'

SOCKET="/tmp/rtorrent.sock"

if ! ARGV.empty?
  then
    rtorrent = SCGIXMLClient.new([SOCKET,"/RPC2"])
    puts rtorrent.call("system.methodSignature","#{ARGV.first}")
    puts rtorrent.call("system.methodHelp","#{ARGV.first}")
  else
    puts "AH AH AH"
end
