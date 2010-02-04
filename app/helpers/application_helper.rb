# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def logo
    if @configuration.logo_image_file_name.blank?
      image_tag "/images/logo.png"
    else
      image_tag @configuration.logo_image.url(:exact)
    end
  end


  def intro_image
    return image_tag "/images/g.headline.png" if @configuration.intro_image_file_name.blank?
    image_tag @configuration.intro_image.url(:exact_width)
  end
  
  
  def configuration_styles
    return if @configuration.header_color.blank?
    %Q{
      #header {
        background-image: url(/images/g.header_gradient.png); 
        background-color: #{@configuration.header_color} !important;
      }
    }
  end

end
