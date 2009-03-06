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

  def pauseResume(id=nil,active=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      if active == "0" then
          sock.call("d.resume",id)
      else
          sock.call("d.pause",id)
      end
      action_cache.delete "/torrent/index"
      update_torrents
      redirect "/torrent"
  end

  def priority_up(id=nil,current_priority=nil,fnum=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      if current_priority == "2" then
          redirect "/torrent/show/#{id}"
          return
      end
      p = current_priority.to_i + 1
      sock.call("f.set_priority",id,fnum.to_i,p)
      action_cache.delete "/torrent/show/#{id}"
      update_files(id)
      redirect "/torrent/show/#{id}"
  end

  def priority_down(id=nil,current_priority=nil,fnum=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      if current_priority == "0" then
          redirect "/torrent/show/#{id}"
          return
      end
      p = current_priority.to_i - 1
      sock.call("f.set_priority",id,fnum.to_i,p)
      action_cache.delete "/torrent/show/#{id}"
      update_files(id)
      redirect "/torrent/show/#{id}"
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

  def print_priority(p)
      case p
      when 0
          return "Off"
      when 1
          return "Normal"
      when 2
          return "High"
      end
  end

  cache :index, :ttl => $conf[:update_time]
  cache :show, :ttl => $conf[:update_time]
end
