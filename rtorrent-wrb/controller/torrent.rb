class TorrentController < Controller
  helper :cache
  helper :auth
  helper :sha1

  before(:index) { login_required }
  before(:show) { login_required }
  
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

  def logout
      action_cache.clear
      super
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
  
  cache :index, :ttl => $conf[:update_time]
  cache :show, :ttl => $conf[:update_time]
end
