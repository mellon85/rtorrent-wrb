class RTorrentApp < RTorrentController
  helper :cache
  helper :auth

  before(:index)             { login_required }
  before(:auth)              { login_required }
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
  before(:print_priority)    { login_required }
  before_all { version }
  
  layout '/nolayout' => [ :button_for_status,
                          :priority_up,
                          :priority_down,
                          :torrent_priority_up,
                          :torrent_priority_down,
                          :upspeed,
                          :downspeed,
                          :free_disk_space]

  def sha1(text)
      require 'digest/sha1'
      Digest::SHA1.hexdigest(text)
  end

  def all
      redirect '/torrent'
  end

  def index
      @title = "rTorrent: All Torrents"
      @torrents = torrents.values 
      @view_name = "All"
  end

  def completed
      @title = "rTorrent: Completed Torrents"
      @torrents = torrents.values
      @torrents.delete_if {|x| x.downloaded < x.size}
      @view_name = "Completed"
      render_template :index
  end

  def seeding
      @title = "rTorrent: Seeding Torrents"
      @torrents = torrents.values
      @torrents.delete_if {|x| x.downloaded < x.size || x.active == 0 }
      @view_name = "Seeding"
      render_template :index
  end

  def downloading
      @title = "rTorrent: Downloading"
      @torrents = torrents.values
      @torrents.delete_if {|x| x.downloaded >= x.size}
      @view_name = "Downloading"
      render_template :index
  end

  def show(id=nil)
      begin
          @peers = show_peers(id)
          # obtain name from rtorrent given the id
          @current_torrent = torrents[id]
          @title = @current_torrent.name
          @hash = id
      rescue Exception => e
          redirect '/torrent'
      end
  end

  def upspeed() 
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      up = sock.call("get_up_rate").to_i / 1024.0
      return sprintf("%.2f", up)
  end
  
  def downspeed() 
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      down = sock.call("get_down_rate").to_i / 1024.0
      return sprintf("%.2f", down)
  end

  def show_peers(id=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      return sock.call("p.multicall",id,"","p.get_address=","p.get_down_rate=","p.get_up_rate=","p.get_down_total=","p.get_up_total=","p.get_completed_percent=")
  end

  def togglePause(id=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      @current_torrent = (torrents)[id] if @current_torrent == nil
      if @current_torrent.active == 0 then
          sock.call("d.resume",id)
          sock.call("d.try_start",id)
      else
          sock.call("d.pause",id)
      end
      action_cache.delete "/torrent/index"
  end

  def remove(id=nil, del=nil)
      @current_torrent = (torrents)[id] if @current_torrent == nil
      if @current_torrent != nil then
          sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
          sock.call("d.stop",id)
          #sock.call("d.delete_link",id)
          if del == 'true' then
            path = sock.call("d.get_base_path",id)
            FileUtils.rm_rf(path)
          end
          sock.call("d.erase",id)
          action_cache.delete "/torrent/index"
      end
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
      end
      redirect "/torrent/show/#{id}"
  end

  def priority_up(id=nil,current_priority=nil,fnum=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      p = (files(id))[fnum.to_i].priority.to_i
      if p < 2 then
          p += 1
          sock.call("f.set_priority",id,fnum.to_i,p)
          action_cache.delete "/torrent/show/#{id}"
      end
      return print_priority(p)
  end

  def priority_down(id=nil,current_priority=nil,fnum=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      p = current_priority.to_i 
      p = (files(id))[fnum.to_i].priority
      if p > 0 then
          p -= 1
          sock.call("f.set_priority",id,fnum.to_i,p)
          action_cache.delete "/torrent/show/#{id}"
      end
      return print_priority(p)
  end

  def torrent_priority_up(id=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      @current_torrent = (torrents)[id] if @current_torrent == nil
      p = @current_torrent.priority.to_i
      if p < 3 then
          p += 1
          sock.call("d.set_priority",id,p);
          action_cache.delete "/torrent/index"
      end
      return print_torrent_priority(p)
  end

  def torrent_priority_down(id=nil)
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      t = torrents[id]
      p = t.priority.to_i
      if p > 0 then
          p -= 1
          sock.call("d.set_priority",id,p);
          action_cache.delete "/torrent/index"
      end
      return print_torrent_priority(p)
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
      $conf[:check_disk] = request[:check_disk]
      save_conf_to_file
      redirect :index
  end

  def setMaxUp
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      up = request[:maxUp]
      sock.call("set_upload_rate", up.to_i*1024)
      redirect :index
  end

  def setMaxDown
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      down = request[:maxDown]
      sock.call("set_download_rate", down.to_i*1024)
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

  def button_for_status(id)
      x = torrents[id]
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

  def free_disk_space
      freespace = []
      if $conf[:check_disk] == nil then
          return [0.to_s]
      end
      $conf[:check_disk].split(',').each do |p|
          freespace << p
          freespace << `df -hP #{p}`.split("\n")[1].split(" ")[3]
      end
      str = ""
      (0..freespace.length/2-1).each do |i|
          str = str+"Available "+freespace[2*i+1]+" on "+freespace[2*i]+"<br>"
      end
      return str
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

  def print_torrent_priority(p)
      case p
      when 0
          return "Off"
      when 1
          return "Low"
      when 2
          return "Normal"
      when 3
          return "High"
      end
  end

  def version
      sock = SCGIXMLClient.new([$conf[:rtorrent_socket],"/RPC2"])
      @pid = sock.call("system.pid")
      @version = sock.call("system.client_version");
      @library = sock.call("system.library_version");
      return
  end

  cache :version, :ttl => 3600
  cache :index, :ttl => $conf[:update_time]
  cache :show, :ttl  => $conf[:update_time]
end
