# Here goes your database connection and options:

require 'rubygems'
require 'sequel'

class Database < Sequel::Migration
    def up
        create_table :torrents do
            column  :name ,:text
            column  :size ,:integer
            column  :upped,:integer
            column  :up   ,:integer
            column  :down ,:integer
            column  :stat ,:integer
            primary_key :torrent_id, :type => :text,
                :auto_increment => false
        end

        create_table :filelists do
            column  :name ,:text
            foreign_key :torrent_id, :table => :torrents, :type => :text
        end

        create_table :trackers do
            column  :url  ,:text
            foreign_key :torrent_id, :table => :torrents, :type => :text
        end
    end

    def down
        drop_table :torrents
        drop_table :filelists
        drop_table :trackers
    end
end

DB = Sequel.sqlite("rtorrent-wrb.sqlite")
