PLATFORM_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/platform.yml")[RAILS_ENV]
MAKER_API_URL = PLATFORM_CONFIG["maker"]
FLASH_DEBUG_MODE = true

SERVER_PARAMS_FOR_FLASH = "&maker_host=#{PLATFORM_CONFIG["maker"]}/&finder_host=#{PLATFORM_CONFIG["finder"]}/&core_host=#{PLATFORM_CONFIG["url"]}/"