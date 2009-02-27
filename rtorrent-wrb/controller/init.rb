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
    if ($last_update + (60*5)) < Time.now then
      #@TODO update data to DB
      torrents = DB[:torrents]
      trackers = DB[:trackers]
      torrentfiles = DB[:torrentfiles]
      torrents.each.update(:updated => '0')
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      tlist = sock.call("download_list", "started")
      tlist.each { |x|
      name, size, uploaded, downloaded, up, down, stat, fnum, tracknum = sock.multicall(["d.get_name","#{x}"],["d.get_size_bytes","#{x}"],["d.get_up_total","#{x}"],["d.get_completed_bytes","#{x}"],["d.get_up_rate","#{x}"],["d.get_down_rate","#{x}"],["d.get_state","#{x}"],["d.get_size_files","#{x}"],["d.get_tracker_size","#{x}"])
      if size<0 then
        chsize, chnum = sock.multicall(["d.get_chunk_size","#{x}"],["d.get_size_chunks","#{x}"])
        size = chsize*chnum
      end
      if uploaded<0 then
        chsize, chnum = sock.multicall(["d.get_chunk_size","#{x}"],["d.get_completed_chunks","#{x}"])
        uploaded = chsize*chnum
      end
      if torrents[:torrent_id => '"#{x}"'] == nil then
        torrents << {:torrent_id=>"#{x}",
                     :name => "#{name}",
                     :size => size, :uploaded => uploaded, :up => up,
                     :downloaded => downloaded,
                     :down => 0, :stat => 0,
                     :updated => 1}
        torrent = Torrent["#{x}"]
        (0..tracknum-1).each { |i|
           tracker = Tracker.new
           tracker.url = sock.call("t.get_url","#{x}",i)
           torrent.add_tracker(tracker)
        }
        (0..fnum-1).each { |i|
           f = Torrentfile.new
           name, size, chdone = sock.multicall(["f.get_path","#{x}",i],["f.get_size_chunks","#{x}",i],["f.get_completed_chunks","#{x}",i])
           f.name = name
           f.size = size
           f.downloaded = chdone*chsize
           torrent.add_torrentfile(f)
        }

      else
        torrents[:torrent_id => '"#{x}"'].update(:name => "#{name}",
                                                :size => size,
                                                :downloaded => downloaded,
                                                :uploaded => uploaded,
                                                :up => up,
                                                :down => down,
                                                :stat => stat,
                                                :updated => 1)
        (0..fnum-1).each { |i|
           name, size, chdone = sock.multicall(["f.get_path","#{x}",i],["f.get_size_chunks","#{x}",i],["f.get_completed_chunks","#{x}",i])
           torrentfiles.filter(:torrent_id => x, :name => name).update(:size => size,
                                                                       :downloaded => chdone*chsize)
        }
        
      end
      }
      torrents.filter('updated = ?', '0').delete
      $last_update = Time.now
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
