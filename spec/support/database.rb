database = Gemika::Database.new
database.connect

database.rewrite_schema! do

  create_table :artists

  create_table :songs do |t|
    t.integer :artist_id
    t.string :genre
    t.integer :year
    t.integer :duration
    t.string :multi_genres, :array => true
    t.json :metadata
  end

  create_table :vinyl_recordings do |t|
    t.integer :year
  end

end
