class Configuration < ActiveRecord::Base
  
  
  has_attached_file :logo_image,  :styles => { 
                                              :exact => "310x49>", 
                                              :medium => "300x300>", 
                                              :thumb => "100x100>" }
  has_attached_file :intro_image, :styles => { 
                                              :exact_width => "828x3000>", 
                                              :medium => "300x300>", 
                                              :thumb => "100x100>" }
  before_update :clear_images
  
  # there has to be an easier way
  attr_accessor :clear_logo_image, :clear_intro_image
  
  
  def clear_images
    self.logo_image = nil if clear_logo_image == 'true' 
    self.intro_image = nil if clear_intro_image == 'true'
    return true
    # self.update_attribute(:logo_image_file_name,  nil) if clear_logo_image == 'true'
    # self.update_attribute(:intro_image_file_name, nil) if clear_intro_image == 'true'
  end
  
end
