require "test_helper"

class Admin::BatteriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = sign_in_admin_as admin_users(:lazaro_nixon)
    @battery = batteries(:one)
  end

  test "should get index" do
    get admin_batteries_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_battery_url
    assert_response :success
  end

  test "should create battery" do
    assert_difference("Battery.count") do
      post admin_batteries_url, params: { battery: { bat: @battery.bat, bkp: @battery.bkp, created_at: @battery.created_at, device_id: @battery.device_id, device_name: @battery.device_name, updated_at: @battery.updated_at, user_id: @battery.user_id, user_name: @battery.user_name } }
    end

    assert_redirected_to admin_battery_url(Battery.last)
  end

  test "should show battery" do
    get admin_battery_url(@battery)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_battery_url(@battery)
    assert_response :success
  end

  test "should update battery" do
    patch admin_battery_url(@battery), params: { battery: { bat: @battery.bat, bkp: @battery.bkp, created_at: @battery.created_at, device_id: @battery.device_id, device_name: @battery.device_name, updated_at: @battery.updated_at, user_id: @battery.user_id, user_name: @battery.user_name } }
    assert_redirected_to admin_battery_url(@battery)
  end

  test "should destroy battery" do
    assert_difference("Battery.count", -1) do
      delete admin_battery_url(@battery)
    end

    assert_redirected_to admin_batteries_url
  end
end
