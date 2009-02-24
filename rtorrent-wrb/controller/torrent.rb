class TorrentController < Controller
  def index
    @title = "rtorrent: torrents"
    @torrents = Torrent.all
  end

end
