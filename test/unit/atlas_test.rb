require File.dirname(__FILE__) + '/../test_helper'

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
  
  context "An atlas" do
    setup do
      make_an_atlas
    end
    
    should "have short description derrived from the full description" do
      assert_equal("First paragraph", @atlas.short_description)
    end
    
    should "have a default map list" do
      make_some_map_lists
      assert_equal(3, @atlas.default_map_list_id)
    end
    
  end

  def make_an_atlas
    @atlas = Atlas.create!( :user => @user, 
                                :title => "Obama's First 100 Days", 
                                :description => "First paragraph\r\nSecond paragraph\r\nThird paragraph.",
                                :url => "obama100" )
  end
  
  def make_some_map_lists
    1.upto(3) {
    @atlas.map_lists.create!( :user => @user,
                               :title => 'MyString',            
                               :description  => 'MyText',        
                               :maker_tag =>  'MyString',        
                               :maker_user  =>  'MyString',       
                               :sort_order => 1,           
                               :maps_sort_order => "1,2",     
                               :default =>  false,
                               :default_map_id =>  1 )
    }
    @atlas.map_lists[2].default = true
  end
  
  def make_another_atlas
    @another_atlas = Atlas.create!( :user => @user, 
                                :title => "Obama's Second 100 Days", 
                                :description => "Description",
                                :url => "obama200" )
  end
    
end
