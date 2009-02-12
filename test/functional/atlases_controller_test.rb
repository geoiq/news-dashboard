require 'test_helper'

class AtlasesControllerTest < ActionController::TestCase
  
  context "on GET for :new" do
    setup do
      login_as(:sam_adams)
      get :new
    end
    should_assign_to :atlas
    should_respond_with :success
    should_render_template :new
  end

  context "on SHOW, a record" do
      setup do
        get :show, :id => atlases(:one).to_param
      end
      
      should_assign_to :atlas
      should_respond_with :success
      should_render_template :show
      should_not_set_the_flash
  end
  
  context "on CREATE of a valid record" do
    setup do
      login_as(:sam_adams)
      post_a_valid_atlas
      @saved_atlas = assigns(:atlas)
    end
    
    should_assign_to :atlas
    should_assign_to :map_lists
    should_redirect_to "user_atlases_url(1)"
    should_change "Atlas.count", :by => 1
    should_change "MapList.count", :by => 2
    
    should "be valid" do
      assert_valid assigns(:atlas)
    end
    
    should "have valid map lists" do
      assert assigns(:map_lists)[0].valid?
      assert assigns(:map_lists)[1].valid?
    end
    
    context "followed by an UPDATE" do
      setup do
        post_an_updated_atlas
        @updated_atlas = Atlas.find(@saved_atlas.id)
      end
      
      should "be valid" do
        assert_valid(@updated_atlas)
      end
      
      should "have maplists with a different updated_at time" do
        assert_not_equal(@saved_atlas.map_lists[1].updated_at, @updated_atlas.map_lists[1].updated_at )
      end
      
      should "have maplists with a different title" do
        assert_equal("UPDATED", @updated_atlas.map_lists[0]["title"])
      end
    end
    
    context "followed by an UPDATE with an addition of another Map List" do
      setup do
        post_an_updated_atlas_with_new_map_list
        @updated_atlas = Atlas.find(@saved_atlas.id)
      end
      should_change "MapList.count", :by => 1
    end
    
    context "followed by a CREATE of a second Atlas with Map Lists" do
      setup do
        post_a_second_atlas
        @second_atlas = assigns(:atlas)
      end
      should_change "Atlas.count", :by => 1
      should_change "MapList.count", :by => 2
    end
    
  end

  context "on CREATE, a valid record with invalid map lists" do
    setup do
      login_as(:sam_adams)
      post_an_atlas_with_invalid_map_lists
    end
    
    should_assign_to :atlas
    should_render_template :new
    should_not_change "Atlas.count"
    should_not_change "MapList.count"
    
    should "be invalid" do
      assert !assigns(:map_lists)[0].valid?
    end
    
    should "have emtpy maplists removed from params" do
      assert_equal 1, assigns(:map_lists).length
    end
    
  end
  
  context "on EDIT" do
    setup do
      login_as(:sam_adams)
      get :edit, :id => atlases(:one).to_param
    end    
    should_assign_to :atlas
  end

  
  # Built in scaffold tests:
  def test_destroy
    login_as(:sam_adams)
    Atlas.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => atlases(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  def test_destroy_with_failure
    login_as(:sam_adams)
    Atlas.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => atlases(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  def test_edit
    login_as(:sam_adams)
    get :edit, :id => atlases(:one).to_param
    assert_response :success
  end

  def test_index
    login_as(:sam_adams)
    get :index
    assert_response :success
    assert_not_nil assigns(:atlases)
  end

  def test_new
    login_as(:sam_adams)
    get :new
    assert_response :success
  end

  def test_show
    get :show, :id => atlases(:one).to_param
    assert_response :success
  end

  # def test_update
  #   login_as(:sam_adams)
  #   Atlas.any_instance.expects(:save).returns(true)
  #   put :update, :id => atlases(:one).to_param, :atlas => { }
  #   assert_response :redirect
  # end

  # def test_update_with_failure
  #   login_as(:sam_adams)
  #   Atlas.any_instance.expects(:save).returns(false)
  #   put :update, :id => atlases(:one).to_param, :atlas => { }
  #   assert_template "edit"
  # end
  
  # __________________________________ Utils __
  def assert_valid(o)
    assert o.valid?, "Overlay invalid because: #{o.errors.full_messages}"
  end
  
  def post_a_valid_atlas
    post :create, {
      :atlas => {
        :title => "Obama's First 100 Days",
        :description => "Description",
        :url => "obama100",
        :user_id => 1 },
      :new_map_lists => {
        "1"=>{"maker_tag"=>"obama100economy", 
              "maker_user"=>"xxx", 
              "title" => "Economy",
              "description" => "Description goes here"},
        "2"=>{"maker_tag"=>"obama100healthcare", 
              "maker_user"=>"xxx", 
              "title" => "Healthcare",
              "description" => "Description goes here"}}
    }
  end
  
  def post_a_second_atlas
    post :create, {
      :atlas => {
        :title => "Second",
        :description => "Second",
        :url => "second",
        :user_id => 1 },
      :new_map_lists => {
        "1"=>{"maker_tag"=>"obama100economy2", 
              "maker_user"=>"xxx2", 
              "title" => "Economy2",
              "description" => "Description goes here"},
        "2"=>{"maker_tag"=>"obama100healthcare2", 
              "maker_user"=>"xxx2", 
              "title" => "Healthcare2",
              "description" => "Description goes here"}}
    }
  end
  
  def post_an_atlas_with_invalid_map_lists
    post :create, {
      :atlas => {
        :title => "Obama's First 100 Days",
        :description => "Description",
        :url => "obama100",
        :user_id => 1 },
      :new_map_lists => {
        "1"=>{"maker_tag"=>"", 
              "maker_user"=>"", 
              "title" => "",
              "description" => "Description goes here"},
        "2"=>{"maker_tag"=>"", 
              "maker_user"=>"", 
              "title" => "",
              "description" => ""}}
    }
  end
  
  def post_an_updated_atlas
    post :update, {
      :id => @saved_atlas.id,
      :atlas => {
        :title => "Obama's First 100 Days",
        :description => "Description",
        :url => "obama100",
        :user_id => 1 },
      :map_lists => {
        @saved_atlas.map_lists[0].id =>{"maker_tag"=>"obama100economy", 
              "maker_user"=>"xxx", 
              "title" => "UPDATED",
              "description" => "Description goes here"},
        @saved_atlas.map_lists[1].id =>{"maker_tag"=>"obama100healthcare", 
              "maker_user"=>"xxx", 
              "title" => "UPDATED TOO",
              "description" => "Description goes here"}}}
  end
  
  def post_an_updated_atlas_with_new_map_list
    post :update, {
      :id => @saved_atlas.id,
      :atlas => {
        :title => "Obama's First 100 Days",
        :description => "Description",
        :url => "obama100",
        :user_id => 1 },
      :map_lists => {
        @saved_atlas.map_lists[0].id =>{"maker_tag"=>"obama100economy", 
              "maker_user"=>"xxx", 
              "title" => "UPDATED",
              "description" => "Description goes here"},
        @saved_atlas.map_lists[1].id =>{"maker_tag"=>"obama100healthcare", 
              "maker_user"=>"xxx", 
              "title" => "UPDATED TOO",
              "description" => "Description goes here"}},
      :new_map_lists => {
        "1"=>{"title"=>"Taxes", "maker_tag"=>"obama100taxes", "maker_user"=>""},
        "2"=>{"title"=>"", "maker_tag"=>"", "maker_user"=>""}}}
  end

end