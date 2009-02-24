class TorrentController < Controller
  
  def index
    @title = "rTorrent: Torrents"
    @torrents = Torrent.all
  end

end
