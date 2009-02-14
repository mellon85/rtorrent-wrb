class CreateTrackers < ActiveRecord::Migration
  def self.up
    create_table :trackers, :id => false do |t|
      t.string :torrent_hash
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :trackers
  end
end
