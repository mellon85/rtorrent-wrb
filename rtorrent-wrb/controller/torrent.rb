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
      if bytes < 1024 then
          "#{bytes} B"
      elsif bytes >= 1024*1024*1024*1024 then
          "#{bytes/1024/1024/1024/1024} TB"
      elsif bytes >= 1024*1024*1024 then
          "#{bytes/1024/1024/1024} GB"
      elsif bytes >= 1024*1024 then
          "#{bytes/1024/1024} MB"
      elsif bytes >= 1024 then
          "#{bytes/1024} KB"
      end
  end
end
