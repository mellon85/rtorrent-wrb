# Here goes your database connection and options:

require 'rubygems'
require 'sequel'

class Torrent < Sequel::Model
    set_primary_key :torrent_id
    one_to_many     :filelists
    one_to_many     :trackers
end

class FileList < Sequel::Model
    no_primary_key
end

class Tracker < Sequel::Model
    no_primary_key
end
