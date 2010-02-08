require 'digest/sha1'
class User < ActiveResource::Base
  self.site = CORE_API_URL
  
  self.headers['platform_key'] = SUPER_SECRET_PLATFORM_KEY

  include NewsUserExtensions

  # Use the user's login instead of ID
  # def to_param
  #   User.login_to_id(login)
  # end

  def initialize(*args)
    super(*args)
    #self.attributes["platform_key"] = SUPER_SECRET_PLATFORM_KEY
    self.attributes["preferences"] ||= nil
    self.attributes["login"] ||= nil
    self.attributes["email"] ||= ""
    self.attributes["full_name"] ||= ""
    self.attributes["password"] ||= nil
    self.attributes["password_confirmation"] ||= nil
    self.attributes["terms_of_use"] ||= nil
    self.attributes["f1token"] ||= nil
    self.attributes["home_group_id"] ||= nil
    self.attributes["group_ids"] ||= nil
    self.attributes["created_at"] ||= Time.now
  end

  # needs overriding or it returns just a string
  def admin?
    self.attributes["admin"] == true.to_s
  end
  
  # This transformation allow logins with periods to get past rails routing
  def self.login_to_id(login)
    URI.encode(login.to_s.gsub(/_/, '__').gsub(/\./, '_-'))
  end
  
  def self.id_to_login(id)
    URI.decode(id.to_s).gsub(/_-/, '.').gsub(/__/, '_')    
  end
  
  def self.find(arg, options = {})
    arg = login_to_id(arg) unless arg.is_a? Symbol
    return super(arg, options) #rescue raise "ARG: #{arg.inspect}"
  end
       
  def copied_overlays
    return []
  end

  def home_group_id
    return self.attributes["home_group_id"].to_i
  end
  
  def self.find_by_login(*args)
    self.find(*args)
  rescue ActiveResource::ResourceNotFound
    return nil
  end
  
  def self.authenticate(username, password)
    s = F1Session.create(:login => username, :password => password)
    RAILS_DEFAULT_LOGGER.info("\n\nSESSION: #{s.inspect}\n\n")
    unless s.nil?
      u = s.User
      return u
    end
  end

  # TODO: this and validate could probably be refactored to share common code
  def self.count
    connection = ActiveResource::Connection.new(PLATFORM_CONFIG['url'])
    url = "/users/count"
    response = connection.get(url, { "platform_key" => SUPER_SECRET_PLATFORM_KEY })
  end
  
  def forget_me
    self.token = nil
    self.save
  end
  
  # only used in one silly place, don't overuse without optimizing.
  def count_shared_overlays
    Overlay.count(
      :conditions => ['uploader_login = ? and shared = ?', self.login, true]
    )
  end
  
  def count_copied_overlays
    Overlay.count(
      :conditions => ['user_login = ? and uploader_login != ?', self.login, self.login]
    )
  end

  #def was_created_at
  #  if self.created_at != nil
  #   return self.created_at.to_date
  # else
  #   return Time.now
  # end
  #end
  
  def new_record?
    return self.new?
  end
  
  def self.authenticate_by_token(login, token)
    u = User.find(login)
    return u if u.f1token == token
    return nil
  end
  
  def get_all_group_ids
    return self.group_ids.split(",") unless self.group_ids.blank?
  end
  
  def password_expired?
    return self.attributes["password_expired"] != "false"
  end
  
  def groups
    return Group.find(:all, :params => { :user_id => self.id })
  end

  def valid?
    validate_on_core
  end

  def validate_on_core
    url = URI.parse("#{PLATFORM_CONFIG['url']}/users/validate")
    connection = ActiveResource::Connection.new(url)
    begin
      response = connection.put(url.path, self.to_xml, { "platform_key" => SUPER_SECRET_PLATFORM_KEY })
      valid = (response.code == "200")
    rescue ActiveResource::ResourceInvalid => error
      self.errors.from_xml(error.response.body)
      valid = false
    end
  end

  protected

  # the xth_user is just to make testing easier
  def first_user_is_an_admin(xth_user=0)
    self.admin = true if User.count == xth_user
  end
  
  # change this and an angel will lose her wings
  def license_restrictions
    if User.count >= MAXIMUM_ACCOUNTS_FOR_LICENSE 
      errors.add_to_base "We are unable to create your account. This software is licensed for #{MAXIMUM_ACCOUNTS_FOR_LICENSE} accounts."
      return false
    end
    return true
  end

end