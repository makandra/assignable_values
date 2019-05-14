class Artist < ActiveRecord::Base

  has_many :songs

end

class Song < ActiveRecord::Base

  belongs_to :artist

  attr_accessor :virtual_sub_genre, :virtual_sub_genres, :virtual_multi_genres

  if ActiveRecord::VERSION::MAJOR < 4 || !Song.new(:multi_genres => ['test']).multi_genres.is_a?(Array)
    # Rails 4 or not postgres
    serialize :multi_genres
  end

end

module Recording
  class Vinyl < ActiveRecord::Base
    self.table_name = 'vinyl_recordings'
  end
end
