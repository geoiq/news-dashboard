class Group < ActiveResource::Base
  self.site = CORE_API_URL
  self.headers['platform_key'] = SUPER_SECRET_PLATFORM_KEY
end