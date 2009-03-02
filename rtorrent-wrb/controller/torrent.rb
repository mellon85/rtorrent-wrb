class TorrentController < Controller
  helper :cache
   
  def index
    update_torrents
    @title = "rTorrent: Torrents"
    @torrents = Torrent.all
  end

  def show(id=nil)
      if Torrent[id] == nil then
          redirect "/torrent"
      else
          update_torrent(id)
          @current_torrent = Torrent[id]
          @title = @current_torrent.name
      end
  end

  private
  
  def convert_bytes(bytes)
      s = 1024.0
      [[s*s*s*s,'TB'],[s*s*s,'GB'],[s*s,'MB'],[s,'KB']].each do |x,t|
          if bytes >= x then
            c = bytes / x
            if ((c % 1) * 100) >= 1 then
                c = sprintf('%.02f',c) 
            else
                c = c.round
            end
            return "#{c} #{t}"
          end
      end
      return "#{bytes} B" 
  end

  def print_ratio(ratio)
      return sprintf('%.02f', ratio/1000.0)
  end

  cache :index, :ttl => $conf[:update_time]
  cache :show, :ttl => $conf[:update_time]
end
