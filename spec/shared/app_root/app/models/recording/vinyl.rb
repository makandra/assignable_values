module Recording
  class Vinyl < ActiveRecord::Base
    self.table_name = 'vinyl_recordings'
    
    serialize :formats, Array
  end
end
