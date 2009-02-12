require 'test_helper'

class BlurbsControllerTest < ActionController::TestCase
  def test_should_get_index
    login_as(:sam_adams)
    get :index
    assert_response :success
    assert_not_nil assigns(:blurbs)
  end

  def test_should_get_new
    login_as(:sam_adams)
    get :new
    assert_response :success
  end

  def test_should_create_blurb
    login_as(:sam_adams)
    assert_difference('Blurb.count') do
      post :create, :blurb => { }
    end

    assert_redirected_to blurbs_path
  end

  def test_should_show_blurb
    get :show, :id => blurbs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    login_as(:sam_adams)
    get :edit, :id => blurbs(:one).id
    assert_response :success
  end

  def test_should_update_blurb
    login_as(:sam_adams)
    put :update, :id => blurbs(:one).id, :blurb => { }
    assert_redirected_to blurbs_path
  end

  def test_should_destroy_blurb
    login_as(:sam_adams)
    assert_difference('Blurb.count', -1) do
      delete :destroy, :id => blurbs(:one).id
    end

    assert_redirected_to blurbs_path
  end
end
