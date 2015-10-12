require 'test_helper'

class MyScaffoldsControllerTest < ActionController::TestCase
  setup do
    @my_scaffold = my_scaffolds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:my_scaffolds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create my_scaffold" do
    assert_difference('MyScaffold.count') do
      post :create, my_scaffold: { contact: @my_scaffold.contact, name: @my_scaffold.name, result: @my_scaffold.result }
    end

    assert_redirected_to my_scaffold_path(assigns(:my_scaffold))
  end

  test "should show my_scaffold" do
    get :show, id: @my_scaffold
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @my_scaffold
    assert_response :success
  end

  test "should update my_scaffold" do
    patch :update, id: @my_scaffold, my_scaffold: { contact: @my_scaffold.contact, name: @my_scaffold.name, result: @my_scaffold.result }
    assert_redirected_to my_scaffold_path(assigns(:my_scaffold))
  end

  test "should destroy my_scaffold" do
    assert_difference('MyScaffold.count', -1) do
      delete :destroy, id: @my_scaffold
    end

    assert_redirected_to my_scaffolds_path
  end
end
