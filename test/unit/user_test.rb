require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should_have_many :atlases
  should_have_many :map_lists
  
end