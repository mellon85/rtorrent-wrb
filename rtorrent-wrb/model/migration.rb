# Here goes your database connection and options:

require 'rubygems'
require 'sequel/extensions/migration'
require 'sequel'

class Database < Sequel::Migration
    def up
        create_table :torrents do
            column  :name ,:text
            column  :size ,:integer
            column  :downloaded,:integer
            column  :uploaded,:integer
            column  :up   ,:integer
            column  :down ,:integer
            column  :updated, :integer
            column  :ratio, :integer
            column  :active, :integer
            column  :priority, :integer
            primary_key :torrent_id, :type => :text,
                        :auto_increment => false
        end

        create_table :torrentfiles do
            column  :name ,:text
            column  :size ,:integer
            column  :downloaded, :integer
            column  :priority, :integer
            foreign_key :torrent_id, :table => :torrents, :type => :text
        end

        create_table :trackers do
            column  :url  ,:text
            foreign_key :torrent_id, :table => :torrents, :type => :text
        end
    end

    def down
        drop_table :torrents
        drop_table :torrentfiles
        drop_table :trackers
    end
end

Database.apply(DB,:up)
