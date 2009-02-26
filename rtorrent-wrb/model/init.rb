# Here goes your database connection and options:

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite

require 'model/migration'
require 'model/models'


#{{{ Test Data
torrents = DB[:torrents]
torrents << {:torrent_id=>"964D6922206AEE2D2BFB49D8B7CD4C0336EBA311",
             :name => "[Xvid - ITA- Sub Ita - AC3] Gattaca.avi",
             :size => 901*1024, :uploaded => 990*1024, :up => 3,
             :downloaded => 901*1024,
             :down => 0, :stat => 0}
torrents << {:torrent_id=>"AEB3239BC8FB27080FFB9C8696CFB236B9159991",
             :name => "Starship.Troopers.3.Marauder.(2008)DVDRip.XviD",
             :size => 1400*1024, :uploaded => 311*1024, :up => 3,
             :downloaded => 1400*1024,
             :down => 0, :stat => 2}

torrent = Torrent["964D6922206AEE2D2BFB49D8B7CD4C0336EBA311"]
ta = Tracker.new
ta.url="http://tracker.tntvillage.scambioetico.org:2710/announce"
torrent.add_tracker(ta)
ta = Tracker.new
ta.url="udp://tracker.tntvillage.scambioetico.org:2710/announce"
torrent.add_tracker(ta)
tf = Torrentfile.new
tf.name="Porno"
tf.size="200"
tf.downloaded="20"
torrent.add_torrentfile(tf)
 
torrent = Torrent["AEB3239BC8FB27080FFB9C8696CFB236B9159991"]
ta = Tracker.new
ta.url="http://tracker.thepiratebay.org/announce"
torrent.add_tracker(ta)
ta = Tracker.new
ta.url="http://www.todotorrents.com:2710/announce"
torrent.add_tracker(ta)
#}}}
