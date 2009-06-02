require 'rubygems'
require 'SCGIxml'

SOCKET="/tmp/rtorrent.socket"

if ! ARGV.empty?
  then
    rtorrent = SCGIXMLClient.new([SOCKET,"/RPC2"])
    puts "signature: #{rtorrent.call("system.methodSignature","#{ARGV.first}")}"
    puts "help: #{rtorrent.call("system.methodHelp","#{ARGV.first}")}"
  else
    puts "Missing arguments"
end
