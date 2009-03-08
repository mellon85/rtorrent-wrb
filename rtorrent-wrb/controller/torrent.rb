class TorrentController < Controller
  helper :cache
  helper :auth
  helper :sha1

  before(:index) { login_required }
  before(:show) { login_required }
  before(:config) { login_required }
  
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
      save_conf_to_file
      redirect '/torrent'
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
