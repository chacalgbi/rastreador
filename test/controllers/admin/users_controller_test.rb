require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = sign_in_admin_as admin_users(:lazaro_nixon)
    @user = users(:one)
  end

  test "should get index" do
    get admin_users_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post admin_users_url, params: { user: { active: @user.active, admin: @user.admin, cars: @user.cars, email_address: @user.email_address, name: @user.name, password_digest: @user.password_digest, phone: @user.phone } }
    end

    assert_redirected_to admin_user_url(User.last)
  end

  test "should show user" do
    get admin_user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch admin_user_url(@user), params: { user: { active: @user.active, admin: @user.admin, cars: @user.cars, email_address: @user.email_address, name: @user.name, password_digest: @user.password_digest, phone: @user.phone } }
    assert_redirected_to admin_user_url(@user)
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete admin_user_url(@user)
    end

    assert_redirected_to admin_users_url
  end
end
