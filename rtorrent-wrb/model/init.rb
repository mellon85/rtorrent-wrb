# Here goes your database connection and options:

# Here go your requires for models:
# require 'model/user'

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite("rtorrent-wrb.sqlite")

require 'model/models'


#Torrents = DB[:torrents]
#Torrents << {:torrent_id=>"hash1"}
#to = Torrent["hash1"]
#
#ta = Tracker.new
#ta.url="url"
#to.add_tracker(ta)

#ta = Tracker.create(:url => "pirate bay")
#to.add_tracker(ta)
