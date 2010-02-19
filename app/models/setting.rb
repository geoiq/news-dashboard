require 'net/https'
class Setting

  CACHE_DURATION = 5.minutes
  
  def self.configuration_from_core
    url = URI.parse(PLATFORM_CONFIG['url'])
    connection = ActiveResource::Connection.new(url)
    connection.get(url.path + "/configuration", { "platform_key" => SUPER_SECRET_PLATFORM_KEY })
  end
  
  def self.current
    return @data unless @data.blank? or cache_expired?
    @cache_expiration = Time.now + CACHE_DURATION
    @data = configuration_from_core
  end

  def self.cache_expired?
    @cache_expiration ||= 1.year.ago
    @cache_expiration < Time.now 
  end
  
  def self.require_login?
    current['require_login']
  end

  def self.strong_passwords?
    current['strong_passwords']
  end

  def self.allow_signup?
    current['allow_signup']
  end
  
  def self.login_blurb
    current['login_blurb']
  end
  
  def self.analytics_key
    current['analytics_key']
  end
  
  def self.everyman_group
    return (self.require_login? ? 0 : -1)
  end
  
  def self.classification_notice
    if current['enable_classification_notice']
      current['classification_notice']
    else
      ''
    end
  end
    
end
