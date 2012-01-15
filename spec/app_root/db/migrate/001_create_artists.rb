class CreateArtists < ActiveRecord::Migration

  def self.up
    create_table :artists
  end

  def self.down
    drop_table :artists
  end
  
end
