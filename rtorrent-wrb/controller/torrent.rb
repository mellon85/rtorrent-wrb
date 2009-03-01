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

  private
  
  def convert_bytes(bytes)
      s = 1024.0
      if bytes < s then
          "#{bytes} B"
      elsif bytes >= s*s*s*s then
          "#{sprintf('%.02f',bytes/s/s/s/s)} TB"
      elsif bytes >= s*s*s then
          "#{sprintf('%.02f',bytes/s/s/s)} GB"
      elsif bytes >= s*s then
          "#{sprintf('%.02f',bytes/s/s)} MB"
      elsif bytes >= s then
          "#{sprintf('%.02f',bytes/s)} KB"
      end
  end
end
