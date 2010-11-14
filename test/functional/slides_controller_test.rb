require 'test_helper'

class SlidesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:slides)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_slide
    assert_difference('Slide.count') do
      post :create, :slide => { }
    end

    assert_redirected_to slide_path(assigns(:slide))
  end

  def test_should_show_slide
    get :show, :id => slides(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => slides(:one).id
    assert_response :success
  end

  def test_should_update_slide
    put :update, :id => slides(:one).id, :slide => { }
    assert_redirected_to slide_path(assigns(:slide))
  end

  def test_should_destroy_slide
    assert_difference('Slide.count', -1) do
      delete :destroy, :id => slides(:one).id
    end

    assert_redirected_to slides_path
  end
end
