require 'test_helper'

class MapListsControllerTest < ActionController::TestCase

  def test_create
    MapList.any_instance.expects(:save).returns(true)
    post :create, :map_list => { }
    assert_response :redirect
  end

  def test_create_with_failure
    MapList.any_instance.expects(:save).returns(false)
    post :create, :map_list => { }
    assert_template "new"
  end

  def test_destroy
    MapList.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => map_lists(:one).to_param
    assert_not_nil flash[:notice]    
    assert_response :redirect
  end

  def test_destroy_with_failure
    MapList.any_instance.expects(:destroy).returns(false)    
    delete :destroy, :id => map_lists(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  def test_edit
    get :edit, :id => map_lists(:one).to_param
    assert_response :success
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:map_lists)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_show
    get :show, :id => map_lists(:one).to_param
    assert_response :success
  end

  def test_update
    MapList.any_instance.expects(:save).returns(true)
    put :update, :id => map_lists(:one).to_param, :map_list => { }
    assert_response :redirect
  end

  def test_update_with_failure
    MapList.any_instance.expects(:save).returns(false)
    put :update, :id => map_lists(:one).to_param, :map_list => { }
    assert_template "edit"
  end

end