class ActiveResource::Connection
  alias :static_default_header :default_header

  def set_header(key, value)
    default_header.update(key => value)
  end
end

class CorePermission < ActiveResource::Base
  self.site = CORE_API_URL
  self.element_name = 'permission'
  # All active resource calls will be with platform key
  connection.set_header('platform_key', SUPER_SECRET_PLATFORM_KEY)

end
