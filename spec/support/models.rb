class Artist < ActiveRecord::Base

  has_many :songs

end

class Song < ActiveRecord::Base

  belongs_to :artist

  attr_accessor :sub_genre, :sub_genres

  if ActiveRecord::VERSION::MAJOR < 4 || !Song.new(:genres => ['test']).genres.is_a?(Array)
    # Rails 4 or not postgres
    serialize :genres
  end

end

module Recording
  class Vinyl < ActiveRecord::Base
    self.table_name = 'vinyl_recordings'
  end
end
