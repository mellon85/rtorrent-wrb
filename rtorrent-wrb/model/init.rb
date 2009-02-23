# Here goes your database connection and options:

# Here go your requires for models:
# require 'model/user'

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :torrents do
    column  :name ,:text
    column  :size ,:integer
    column  :upped,:integer
    column  :up   ,:integer
    column  :down ,:integer
    column  :stat ,:integer
    primary_key :torrent_id, :type => :text, :auto_increment => false
end

DB.create_table :filelists do
    column  :name ,:text
    foreign_key :torrent_id, :table => :torrents, :type => :text
    #primary_key :id
end

DB.create_table :trackers do
    column  :url  ,:text
    foreign_key :torrent_id, :table => :torrents, :type => :text
    #primary_key :id
end

class Torrent < Sequel::Model
    set_primary_key :torrent_id
    one_to_many     :filelists
    one_to_many     :trackers
end

class FileList < Sequel::Model
    #set_primary_key :id
    no_primary_key
end

class Tracker < Sequel::Model
    #set_primary_key :id
    no_primary_key
end

Torrents = DB[:torrents]
Torrents << {:torrent_id=>"hash1"}
to = Torrent["hash1"]

ta = Tracker.new
ta.url="url"
to.add_tracker(ta)

#ta = Tracker.create(:url => "pirate bay")
#to.add_tracker(ta)
