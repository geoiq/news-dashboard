require 'test_helper'

class MainControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  
  context "on GET index" do
    setup do
      get :index
    end
    should_respond_with :success
  end
  


end
