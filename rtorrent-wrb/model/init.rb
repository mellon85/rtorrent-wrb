# Here goes your database connection and options:

# Here go your requires for models:
# require 'model/user'

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite

require 'model/models'
require 'model/migration'

Torrents = DB[:torrents]
Torrents << {:torrent_id=>"hash1"}
Torrents << {:torrent_id=>"hash2"}
to = Torrent["hash1"]

#ta = Tracker.new
#ta.url="url"
#to.add_tracker(ta)

#ta = Tracker.create(:url => "pirate bay")
#to.add_tracker(ta)
