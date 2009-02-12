require 'test_helper'

class MapListTest < ActiveSupport::TestCase

  should_belong_to :user
  
  should_require_attributes :title
  
end
