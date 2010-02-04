class Configuration < ActiveRecord::Base
  
  has_attached_file :logo_image,  :styles => { 
                                              :exact => "310x49>", 
                                              :medium => "300x300>", 
                                              :thumb => "100x100>" }
  has_attached_file :intro_image, :styles => { 
                                              :exact_width => "828x3000>", 
                                              :medium => "300x300>", 
                                              :thumb => "100x100>" }
  
  
  
end
