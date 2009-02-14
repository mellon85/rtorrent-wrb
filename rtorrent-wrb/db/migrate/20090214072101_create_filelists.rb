class CreateFilelists < ActiveRecord::Migration
  def self.up
    create_table :filelists  do |t|
      t.string :torrent_hash
      t.string :name
      t.integer :size
      t.integer :downloaded
    end
  end

  def self.down
    drop_table :filelists
  end
end
