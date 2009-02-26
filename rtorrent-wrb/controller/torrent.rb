class TorrentController < Controller
  
  def index
    check_update
    @title = "rTorrent: Torrents"
    @torrents = Torrent.all
  end

  def show(id=nil)
      check_update
      @current_torrent = Torrent[id]
      if @current_torrent == nil then
          redirect "/torrent"
      else
          @title = @current_torrent[:name]
      end
  end

end
