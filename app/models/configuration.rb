class Configuration < ActiveRecord::Base
  
  has_attached_file :logo_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  has_attached_file :intro_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  
  
  
end
