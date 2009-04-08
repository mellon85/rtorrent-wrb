class TorrentController < Controller
  helper :cache
  helper :auth
  helper :sha1
  helper :partial

  before(:index)             { login_required }
  before(:completed)         { login_required }
  before(:seeding)           { login_required }
  before(:downloading)       { login_required }
  before(:show)              { login_required }
  before(:config)            { login_required }
  before(:send_torrent)      { login_required }
  before(:receive_torrent)   { login_required }
  before(:save_config)       { login_required }
  before(:togglePause)       { login_required }
  before(:remove)            { login_required }
  before(:set_priority)      { login_required }
  before(:priority_up)       { login_required }
  before(:priority_down)     { login_required }
  before(:button_for_status) { login_required }
  
  def all
      redirect '/torrent'
  end

  def index
      update_torrents
      @title = "rTorrent: All Torrents"
      @torrents = Torrent.all
      @view_name = "All"
  end

  def completed
      update_torrents
      @title = "rTorrent: Completed Torrents"
      @torrents = Torrent.filter(:downloaded >= :size)
      @view_name = "Completed"
      render_template :index
  end

  def seeding
      update_torrents
      @title = "rTorrent: Seeding"
      @torrents = Torrent.filter(:downloaded >= :size).filter(:active => 1)
      @view_name = "Seeding"
      render_template :index
  end

  def downloading
      update_torrents
      @title = "rTorrent: Downloading"
      @torrents = Torrent.filter(:downloaded < :size)
      @view_name = "Downloading"
      render_template :index
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

  def togglePause(id=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      if Torrent[id].active == 0 then
          sock.call("d.resume",id)
          sock.call("d.try_start",id)
      else
          sock.call("d.pause",id)
      end
      update_torrents
      action_cache.delete "/torrent/index"
  end

  def remove(id=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      #sock.call("d.delete_link",id)
      sock.call("d.stop",id)
      sock.call("d.erase",id)
      action_cache.delete "/torrent/index"
      update_torrents
      redirect "/torrent"
  end

  def set_priority
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      id, files, priority = request[:torrentID, :selectedFiles, :priority]
      if files != nil
          files.each do |f|
              sock.call("f.set_priority",id,f.to_i,priority)
          end
          action_cache.delete "/torrent/show/#{id}"
          update_files(id)
      end
      redirect "/torrent/show/#{id}"
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

  def logout
      action_cache.clear
      super
  end

  def save_config
      $conf[:port] = request[:port].to_i
      $conf[:rtorrent_socket] = request[:socket]
      if request[:password] != "" then 
          $conf[:passwordSHA1] = sha1(request[:password])
      end
      $conf[:update_time]  = request[:update_time].to_i
      $conf[:username]     = request[:username]
      $conf[:torrent_save_path] = request[:save_path]
      save_conf_to_file
      redirect :index
  end

  def send_torrent
      @title="Send Torrent"
  end

  def receive_torrent
      tempfile, filename, @type =
                request[:torrent].values_at(:tempfile, :filename, :type)
      @extname, @basename = File.extname(filename), File.basename(filename)
      mode = request[:upload_type]
      if @extname == ".torrent" then
          if mode == "xmlrpc" then
              sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
              sock.call("load",tempfile.path)
          else
              FileUtils.move(tempfile.path, "#{mode}/#{@basename}")
          end
              action_cache.delete "/torrent/index"
              redirect '/torrent'
      else
          FileUtils.rm(tempfile.path)
          @title = "Error sending torrent_file"
      end
  end

  layout '/nolayout' => [ :button_for_status ]
  def button_for_status(id)
      x = Torrent[id]
      if x.active != 1 then
          if x.downloaded >= x.size then
              return "start_seed"
          else
              return "start"
          end
      else
          if x.downloaded >= x.size then
              return "pause_seed"
          else
              return "pause"
          end
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

    

  def login_required
    flash[:error] = 'login required to view that page' unless logged_in?
    super
  end

  def check_auth user, pass
    return false if (not user or user.empty?) and (not pass or pass.empty?)
    pass = sha1(pass)
    if user == $conf[:username] && pass == $conf[:passwordSHA1] then
        true
    else
      flash[:error] = 'invalid username or password'
      false
    end
  end
  
  cache :index, :ttl => $conf[:update_time]
  cache :show, :ttl => $conf[:update_time]
end
