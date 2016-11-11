class Artist < ActiveRecord::Base

  has_many :songs

end


class Song < ActiveRecord::Base

  belongs_to :artist

  attr_accessor :sub_genre

end

module Recording
  class Vinyl < ActiveRecord::Base
    self.table_name = 'vinyl_recordings'
  end
end
