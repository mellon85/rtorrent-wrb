class Torrent < ActiveRecord::Base
    set_primary_key :torrent_hash
    validates_presence_of :torrent_hash
end
