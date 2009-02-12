class Blurb < ActiveRecord::Base
  
  def published?
    true if published_at.nil?
    true if published_at <= Time.now
  end
  
  def self.display(key)
    blurb = Blurb.find_by_key(key)
    if blurb and !blurb.body.empty?
      RDiscount.new(blurb.body).to_html
    else
      %Q{["#{key}" will be displayed here.]}
    end
  end
  
end
