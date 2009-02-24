# Here goes your database connection and options:

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite

require 'model/models'
require 'model/migration'

torrents = DB[:torrents]
torrents << {:torrent_id=>"hash1"}
torrents << {:torrent_id=>"hash2"}
to = Torrent["hash1"]

#ta = Tracker.new
#ta.url="url"
#to.add_tracker(ta)
#ta = Tracker.create(:url => "pirate bay")
#to.add_tracker(ta)
