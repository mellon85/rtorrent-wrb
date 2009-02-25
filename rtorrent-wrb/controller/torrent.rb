class TorrentController < Controller
  
  def index
    check_update
    @title = "rTorrent: Torrents"
    @torrents = Torrent.all
  end

  def show(id=nil)
      @current_torrent = Torrent[id]
      if @current_torrent == nil then
          @title = "Error"
          return "Error! torrent not found"
      else
          @title = @current_torrent[:name]
      end
  end

end
