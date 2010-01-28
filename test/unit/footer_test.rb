require File.dirname(__FILE__) + '/../test_helper'

class FooterTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  context "The custom footer space" do
    
    should "be empty at first" do
      @footer = Footer.last
      assert_equal(@footer.link,"")
    end

  end
  
  

end
