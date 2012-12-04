class CreateRecordings < ActiveRecord::Migration

  def self.up
    create_table :vinyl_recordings do |t|
      t.integer :year
      t.string :formats
    end
  end

  def self.down
    drop_table :vinyl_recordings
  end

end
