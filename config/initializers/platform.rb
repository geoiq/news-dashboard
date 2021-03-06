PLATFORM_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/platform.yml")[RAILS_ENV]
CORE_API_URL = PLATFORM_CONFIG["url"]
MAKER_API_URL = PLATFORM_CONFIG["maker"]
FINDER_API_URL = PLATFORM_CONFIG["finder"]
FLASH_DEBUG_MODE = true

SUPER_SECRET_PLATFORM_KEY = Digest::MD5.hexdigest(INSTANCE_ID) + "820bfd0a437507c04cd256a97fe05b78"

SERVER_PARAMS_FOR_FLASH = "&maker_host=#{PLATFORM_CONFIG["maker"]}/&finder_host=#{PLATFORM_CONFIG["finder"]}/&core_host=#{PLATFORM_CONFIG["url"]}/"