class Torrent < ActiveRecord::Base
    set_primary_key :torrent_hash
    validates_presence_of :torrent_hash
    has_many :tracker, :foreign_key => :torrent_hash
end
