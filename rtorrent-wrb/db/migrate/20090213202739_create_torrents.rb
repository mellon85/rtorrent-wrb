class CreateTorrents < ActiveRecord::Migration
  def self.up
    create_table :torrents, :id => false, :primary_key => :torrent_hash do |t|
      t.string  :name
      t.integer :size
      t.integer :upped
      t.integer :downloaded
      t.integer :up_rate
      t.integer :down_rate
      t.string  :torrent_hash, :null => false
      t.integer :status
    end
  end

  def self.down
    drop_table :torrents
  end
end
