# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def logo
    if @configuration.logo_image_file_name.blank?
      image_tag "/images/logo.png"
    else
      image_tag @configuration.logo_image.url
    end
  end

end
