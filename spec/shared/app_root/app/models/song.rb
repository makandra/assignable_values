class Song < ActiveRecord::Base

  belongs_to :artist

  attr_accessor :sub_genre

end
