require "test_helper"

class Admin::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = sign_in_admin_as admin_users(:lazaro_nixon)
    @event = events(:one)
  end

  test "should get index" do
    get admin_events_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_event_url
    assert_response :success
  end

  test "should create event" do
    assert_difference("Event.count") do
      post admin_events_url, params: { event: { car_id: @event.car_id, car_name: @event.car_name, created_at: @event.created_at, driver_id: @event.driver_id, driver_name: @event.driver_name, event_name: @event.event_name, event_type: @event.event_type, message: @event.message, updated_at: @event.updated_at } }
    end

    assert_redirected_to admin_event_url(Event.last)
  end

  test "should show event" do
    get admin_event_url(@event)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_event_url(@event)
    assert_response :success
  end

  test "should update event" do
    patch admin_event_url(@event), params: { event: { car_id: @event.car_id, car_name: @event.car_name, created_at: @event.created_at, driver_id: @event.driver_id, driver_name: @event.driver_name, event_name: @event.event_name, event_type: @event.event_type, message: @event.message, updated_at: @event.updated_at } }
    assert_redirected_to admin_event_url(@event)
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete admin_event_url(@event)
    end

    assert_redirected_to admin_events_url
  end
end
