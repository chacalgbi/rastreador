require "test_helper"

class Admin::NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = sign_in_admin_as admin_users(:lazaro_nixon)
    @notification = notifications(:one)
  end

  test "should get index" do
    get admin_notifications_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_notification_url
    assert_response :success
  end

  test "should create notification" do
    assert_difference("Notification.count") do
      post admin_notifications_url, params: { notification: { created_at: @notification.created_at, email: @notification.email, id: @notification.id, telegram: @notification.telegram, updated_at: @notification.updated_at, user_id: @notification.user_id, whatsapp: @notification.whatsapp } }
    end

    assert_redirected_to admin_notification_url(Notification.last)
  end

  test "should show notification" do
    get admin_notification_url(@notification)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_notification_url(@notification)
    assert_response :success
  end

  test "should update notification" do
    patch admin_notification_url(@notification), params: { notification: { created_at: @notification.created_at, email: @notification.email, id: @notification.id, telegram: @notification.telegram, updated_at: @notification.updated_at, user_id: @notification.user_id, whatsapp: @notification.whatsapp } }
    assert_redirected_to admin_notification_url(@notification)
  end

  test "should destroy notification" do
    assert_difference("Notification.count", -1) do
      delete admin_notification_url(@notification)
    end

    assert_redirected_to admin_notifications_url
  end
end
