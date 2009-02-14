class CreateTrackers < ActiveRecord::Migration
  def self.up
    create_table :trackers do |t|
      t.string :torrent_hash
      t.string :url
    end
  end

  def self.down
    drop_table :trackers
  end
end
