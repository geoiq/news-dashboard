class Atlas < ActiveRecord::Base

  belongs_to :user
  has_many :map_lists, :order => :sort_order
  validates_associated :map_lists
  
  validates_uniqueness_of :url
  validates_presence_of :description
  validates_presence_of :title
  
  validates_format_of :url, :with => /^[\w\d]+$/, :on => :create, :message => "is invalid"
  
  named_scope :listed    , :conditions => { :listed => true 	 } 
  named_scope :unlisted  , :conditions => { :listed => false  }
  named_scope :latest_first , :order =>  'created_at desc'
  
  def short_description
    description.split("\r\n").first
  end
  
end
