# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

$last_update = Time.at(0)
$conf = {:rtorrent_socket => "/tmp/rtorrent.sock",
         :username        => "",
         :passwordSHA1    => "",
         :update_time     => 60,
         :port            => 7000}

class Controller < Ramaze::Controller
  layout '/page'
  helper :xhtml
  engine :Ezamar

  def check_update
    if true then #($last_update + (60*5)) < Time.now then
      # update data to DB
      DB.transaction do
      Torrent.update(:updated => '0')
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      tlist = sock.call("download_list", "started")
      tlist.each do |x|
          name, size, uploaded, downloaded, up, down, stat, fnum, tracknum,
              chsize, chnum =
            sock.multicall(["d.get_name",x],["d.get_size_bytes",x],
                           ["d.get_up_total",x],["d.get_completed_bytes",x],
                           ["d.get_up_rate",x],["d.get_down_rate",x],
                           ["d.get_state",x],["d.get_size_files",x],
                           ["d.get_tracker_size",x],
                           ["d.get_chunk_size",x],["get_size_chunks",x])
          size = chsize*chnum if size < 0
          if uploaded < 0 then
            chnum = sock.call("d.get_completed_chunks",x)
            uploaded = chsize*chnum
          end
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
            torrent.down = 0 
            torrent.stat = 0
            torrent.updated = 1
            Torrent.insert(torrent)

            # Add trackers
            (0..tracknum-1).each do |i|
               tracker = Tracker.new
               tracker.url = sock.call("t.get_url","#{x}",i)
               torrent = Torrent[x]
               torrent.add_tracker(tracker)
            end
            
            # Add files
            (0..fnum-1).each do |i|
               f = Torrentfile.new
               name, size, chsize, chdone, priority =
                   sock.multicall(["f.get_path",x,i],
                                  ["f.get_size_bytes",x,i],
                                  ["f.get_size_chunks",x,i],
                                  ["f.get_completed_chunks",x,i],
                                  ["f.get_priority",x,i])
               f.name = name
               f.size = size
      # 'f.get_range_first' may identify how chunk are for the file?
      # 'f.get_range_second' if size < 0
               f.downloaded = f.size
               f.downloaded = chdone*chsize if chdone*chsize < f.size 
               torrent.add_torrentfile(f)
            end
          else
            # Update torrent
            torrent.update(
                :name => name, :size => size,
                :downloaded => downloaded,
                :uploaded => uploaded,
                :up => up, :down => down,
                :stat => stat, :updated => 1)
            (0..fnum-1).each do |i|
               name, size, chdone, priority =
                   sock.multicall(["f.get_path",x,i],
                                  ["f.get_size_chunks",x,i],
                                  ["f.get_completed_chunks",x,i],
                                  ["f.get_priority",x,i])
               Torrentfile.filter(:torrent_id => x).filter(:name => name).update(
                   :size => size*chsize,:downloaded => chdone*chsize, :priority => priority)
            end
          end
      end
      Torrent.filter('updated = ?', '0').delete
      $last_update = Time.now
      end
    end
  end
end

# load program configuration
$conf = YAML.load_file("rtorrent-wrb.conf")

# save coniguration file
# f = File.open("rtorrent-wrb.conf")
# f.write(YAML.dump($conf))
# f.close

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/torrent'
require 'SCGIxml'
