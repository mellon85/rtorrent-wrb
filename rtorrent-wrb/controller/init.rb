# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers
#

$conf = {:rtorrent_socket => "/tmp/rtorrent.sock",
         :username        => "",
         :passwordSHA1    => "",
         :update_time     => 60,
         :port            => 7000,
         :torrent_save_path => "/tmp"}

class Controller < Ramaze::Controller
  layout '/page'
#  helper :xhtml
  engine :Ezamar

  protected

  def update_files(id)
    sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
    DB.transaction do
        torrent = Torrent[id] 
        fnum, chsize = sock.multicall(["d.get_size_files",id], ["d.get_chunk_size",id])
        if torrent.torrentfiles.length == 0 then
            (0..fnum-1).each do |i|
                f = Torrentfile.new
                f.name, f.size, chnum, chdone, f.priority = 
                    sock.multicall(["f.get_path",id,i],["f.get_size_bytes",id,i],
                                         ["f.get_size_chunks",id,i],
                                         ["f.get_completed_chunks",id,i],
                                         ["f.get_priority",id,i])
                f.downloaded = f.size
                f.downloaded = chdone*chsize if chdone*chsize < f.size 
                torrent.add_torrentfile(f)
            end
        else
            (0..fnum-1).each do |i|
                name, size, chnum, chdone, priority =
                    sock.multicall(["f.get_path",id,i], ["f.get_size_bytes",id,i],
                                   ["f.get_size_chunks",id,i],
                                   ["f.get_completed_chunks",id,i],
                                   ["f.get_priority",id,i])
                done = size
                done = chdone*chsize if chdone*chsize < size
                Torrentfile.filter(:torrent_id => id).filter(:name => name).update(
                    :downloaded => done, :priority => priority)
            end
        end
     end
  end

  def update_trackers(id)
    sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
    DB.transaction do
        torrent = Torrent[id] 
        if torrent.torrentfiles.length == 0 then
            num    = sock.call("d.get_tracker_size",id)
            (0..num-1).each do |i|
                tracker = Tracker.new
                tracker.url = sock.call("t.get_url",id,i)
                torrent = Torrent[id]
                torrent.add_tracker(tracker)
            end
        end
    end
  end

  def update_torrent(x)
      DB.transaction do
          update_trackers(x)
          update_files(x)
      end
  end

  def update_torrents
      DB.transaction do
      Torrent.update(:updated => '0')
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      tlist = sock.call("download_list", "main")
      tlist.each do |x|
          name, size, downloaded, up, down, fnum, tracknum,
              chsize, chnum, chcmp, ratio, active, done, prio =
            sock.multicall(["d.get_name",x],["d.get_size_bytes",x],
                           ["d.get_completed_bytes",x],
                           ["d.get_up_rate",x],["d.get_down_rate",x],
                           ["d.get_size_files",x],
                           ["d.get_tracker_size",x],
                           ["d.get_chunk_size",x],["d.get_size_chunks",x],
                           ["d.get_completed_chunks",x],["d.get_ratio",x],
                           ["d.is_active",x],["d.get_complete",x],
                           ["d.get_priority",x])
          size = chsize*chnum if size < chsize*chnum
          downloaded = chsize*chcmp if downloaded < chsize*chcmp
          uploaded = downloaded*ratio/1000.0

          torrent = Torrent[x]
          if torrent == nil then
            # Create new Torrent
            torrent = Torrent.new
            torrent.torrent_id = "#{x}"
            torrent.name = "#{name}"
            torrent.size = size 
            torrent.uploaded = uploaded
            torrent.up = up
            torrent.downloaded = downloaded
            torrent.down = down
            torrent.updated = 1
            torrent.ratio = ratio
            torrent.active = active
            torrent.priority = prio
            Torrent.insert(torrent)
          else
            # Update torrent
            torrent.update(
                :name => name, :size => size,
                :downloaded => downloaded,
                :uploaded => uploaded,
                :up => up, :down => down,
                :updated => 1,
                :ratio => ratio, :active => active,
                :priority => prio)
          end
      end
      Torrent.filter('updated = ?', '0').delete
      end
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
