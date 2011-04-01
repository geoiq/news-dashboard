class Blurb < ActiveRecord::Base
  
  before_validation :sanitize_input
  
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
  
  private
  
  def sanitize_input
    self.body = Sanitize.clean(body, Sanitize::Config::RELAXED)
    self.title = Sanitize.clean(title, Sanitize::Config::RELAXED)
  end
end
