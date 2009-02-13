require 'test_helper'

class TrackersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trackers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trackers" do
    assert_difference('Trackers.count') do
      post :create, :trackers => { }
    end

    assert_redirected_to trackers_path(assigns(:trackers))
  end

  test "should show trackers" do
    get :show, :id => trackers(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trackers(:one).id
    assert_response :success
  end

  test "should update trackers" do
    put :update, :id => trackers(:one).id, :trackers => { }
    assert_redirected_to trackers_path(assigns(:trackers))
  end

  test "should destroy trackers" do
    assert_difference('Trackers.count', -1) do
      delete :destroy, :id => trackers(:one).id
    end

    assert_redirected_to trackers_path
  end
end
