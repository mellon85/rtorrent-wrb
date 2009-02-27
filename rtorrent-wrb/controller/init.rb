# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

$last_update = Time.at(0)
$conf = {:rtorrent_socket => "",
         :username        => "",
         :passwordSHA1    => "",
         :update_time     => 60,
         :port            => 7000}

class Controller < Ramaze::Controller
  layout '/page'
  helper :xhtml
  engine :Ezamar

  def check_update
      if ($last_update + $conf[:update_time]) < Time.now then
          #@TODO update data to DB
          $last_update = Time.now
      end
  end
end

# load program configuration
$conf = YAML.load_file("rtorrent-wrb.conf")

# save coniguration file
# f = File.open("rtorrent-wrb.conf")
# f.write(YAML.dump($conf))
# f.close

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/torrent'

