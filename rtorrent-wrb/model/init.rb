# Here goes your database connection and options:

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite

require 'model/models'
require 'model/migration'

torrents = DB[:torrents]
torrents << {:torrent_id=>"964D6922206AEE2D2BFB49D8B7CD4C0336EBA311",
             :name => "[Xvid - ITA- Sub Ita - AC3] Gattaca.avi",
             :size => 901*1024, :upped => 990*1024, :up => 3,
             :down => 0, :stat => 0}
torrents << {:torrent_id=>"AEB3239BC8FB27080FFB9C8696CFB236B9159991",
             :name => "Starship.Troopers.3.Marauder.(2008)DVDRip.XviD",
             :size => 1400*1024, :upped => 311*1024, :up => 3,
             :down => 0, :stat => 2}
to = Torrent["hash1"]

#ta = Tracker.new
#ta.url="url"
#to.add_tracker(ta)
#ta = Tracker.create(:url => "pirate bay")
#to.add_tracker(ta)
