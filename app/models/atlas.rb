class Atlas < ActiveRecord::Base

  belongs_to :user
  has_many :map_lists
  validates_associated :map_lists
  
  validates_uniqueness_of :url
  validates_presence_of :description
  validates_presence_of :title
  
  validates_format_of :url, :with => /^[\w\d]+$/, :on => :create, :message => "is invalid"
  
end
