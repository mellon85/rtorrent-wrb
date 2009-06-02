# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers
#

$conf = {:rtorrent_socket => "/tmp/rtorrent.sock",
         :username        => "admin",
         :passwordSHA1    => "d033e22ae348aeb5660fc2140aec35850c4da997",
         :update_time     => 60,
         :port            => 7000,
         :torrent_save_path => "/tmp"}

class Controller < Ramaze::Controller
  layout '/page'
#  helper :xhtml
  engine :Ezamar

  protected

  def files(id)
    sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
    files = []
    fnum, chsize = sock.multicall(["d.get_size_files",id], ["d.get_chunk_size",id])
    tmpTorrents = sock.call("f.multicall",id,"","f.get_path=","f.get_size_bytes=",
                            "f.get_size_chunks=","f.get_completed_chunks=","f.get_priority=")
    
    tmpTorrents.each do |t|
        size = t[1]
        chnum = t[2]
        chdone = t[3]
        downloaded = t[1]
        downloaded = chdone*chsize if chdone*chsize < f.size
        files << TorrentFile.new(t[0],t[1],downloaded,t[4])
     end
     return files
  end

  def trackers(id)
    sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
    tmpTrackers = sock.call("t.multicall",id,"","t.get_url=")
    trackers = []
    tmpTrackers.each do |t|
        trackers << Tracker.new(t[0])
    end
    return trackers
  end

  def torrents
      torrents = {}
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      ids = torrents.keys
      tlist = sock.call("d.multicall","","d.get_name=","d.get_size_bytes=",
                           "d.get_completed_bytes=",
                           "d.get_up_rate=","d.get_down_rate=",
                           "d.get_size_files=",
                           "d.get_tracker_size=",
                           "d.get_chunk_size=","d.get_size_chunks=",
                           "d.get_completed_chunks=","d.get_ratio=",
                           "d.is_active=","d.get_complete=",
                           "d.get_priority=","d.get_hash=")
      tlist.each do |t|
          chsize = t[7]
          chnum = t[8]
          chcmp = t[9]
          size = t[1]
          id = t[14]

          size = chsize*chnum if size < chsize*chnum
          downloaded = chsize*chcmp if downloaded < chsize*chcmp
          uploaded = downloaded*ratio/1000.0
          
          torrent = Torrent.new(t[0],size,downloaded,uploaded,t[3],t[4],
                                t[10],t[11],t[13],t[14])
          torrents[id] = torrent
      end
      return torrents
  end
end

CONF_FILE="#{ENV['HOME']}/.rtorrent-wrb.conf"

def save_conf_to_file()
    f = File.open(CONF_FILE,"w")
    f.write(YAML.dump($conf))
    f.close
end

# load program configuration
begin
    $conf = YAML.load_file(CONF_FILE)
rescue
    save_conf_to_file()
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/torrent'
require 'SCGIxml'
