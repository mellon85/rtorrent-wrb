require 'test_helper'

class FilelistsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:filelists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create filelist" do
    assert_difference('Filelist.count') do
      post :create, :filelist => { }
    end

    assert_redirected_to filelist_path(assigns(:filelist))
  end

  test "should show filelist" do
    get :show, :id => filelists(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => filelists(:one).id
    assert_response :success
  end

  test "should update filelist" do
    put :update, :id => filelists(:one).id, :filelist => { }
    assert_redirected_to filelist_path(assigns(:filelist))
  end

  test "should destroy filelist" do
    assert_difference('Filelist.count', -1) do
      delete :destroy, :id => filelists(:one).id
    end

    assert_redirected_to filelists_path
  end
end
