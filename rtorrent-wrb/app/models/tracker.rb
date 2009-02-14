class Tracker < ActiveRecord::Base
    validates_presence_of :torrent_hash, :url
    belongs_to :torrent, :foreign_key => :torrent_hash
end
