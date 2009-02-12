require 'test_helper'

class AtlasTest < ActiveSupport::TestCase

  should_belong_to :user
  should_have_many :map_lists
  should_require_attributes :title
  should_require_attributes :description
  
  should_require_unique_attributes :url
  should_not_allow_values_for :url, "eeegads!", "eee gads"
  should_allow_values_for     :url, "eeeegads", "eee_gads"
  
  context "An Atlas should" do
    setup do
      @atlas = Atlas.find(:first)
    end
        
  end
  
  context "A user has several atlases" do
    setup do
      @user = User.find(:first)
      make_an_atlas
      make_another_atlas
    end
    
    should "be valid" do
      assert @atlas.valid?
    end
    
    should "and should be assigned to a user" do
      assert_equal(4, @user.atlases.count)  # fixtures sets up 2 before this runs
    end
    
  end

  def make_an_atlas
    @atlas = Atlas.create!( :user => @user, 
                                :title => "Obama's First 100 Days", 
                                :description => "Description",
                                :url => "obama100" )
  end
  
  def make_another_atlas
    @another_atlas = Atlas.create!( :user => @user, 
                                :title => "Obama's Second 100 Days", 
                                :description => "Description",
                                :url => "obama200" )
  end
    
end
