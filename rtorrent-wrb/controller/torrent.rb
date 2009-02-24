class TorrentController < Controller
  
  def index
      check_update
    @title = "rTorrent: Torrents"
    @torrents = Torrent.all
  end

end
