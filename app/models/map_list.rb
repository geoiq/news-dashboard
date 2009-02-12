class MapList < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :atlas
  
  validates_presence_of :title
  
end
