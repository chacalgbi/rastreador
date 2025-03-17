require "test_helper"

class Admin::DetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = sign_in_admin_as admin_users(:lazaro_nixon)
    @detail = details(:one)
  end

  test "should get index" do
    get admin_details_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_detail_url
    assert_response :success
  end

  test "should create detail" do
    assert_difference("Detail.count") do
      post admin_details_url, params: { detail: { acc: @detail.acc, acc_virtual: @detail.acc_virtual, alert_email: @detail.alert_email, alert_telegram: @detail.alert_telegram, alert_whatsApp: @detail.alert_whatsApp, apn: @detail.apn, bat_bck: @detail.bat_bck, bat_nivel: @detail.bat_nivel, battery: @detail.battery, cercas: @detail.cercas, charge: @detail.charge, created_at: @detail.created_at, device_id: @detail.device_id, device_name: @detail.device_name, heartbeat: @detail.heartbeat, horimetro: @detail.horimetro, ignition: @detail.ignition, imei: @detail.imei, ip_and_port: @detail.ip_and_port, last_event_type: @detail.last_event_type, model: @detail.model, network: @detail.network, obs: @detail.obs, odometro: @detail.odometro, params: @detail.params, rele_state: @detail.rele_state, satelites: @detail.satelites, send_battery: @detail.send_battery, send_exit_cerca: @detail.send_exit_cerca, send_rele: @detail.send_rele, send_velo_max: @detail.send_velo_max, signal_gps: @detail.signal_gps, signal_gsm: @detail.signal_gsm, status: @detail.status, updated_at: @detail.updated_at, url: @detail.url, velo_max: @detail.velo_max, version: @detail.version } }
    end

    assert_redirected_to admin_detail_url(Detail.last)
  end

  test "should show detail" do
    get admin_detail_url(@detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_detail_url(@detail)
    assert_response :success
  end

  test "should update detail" do
    patch admin_detail_url(@detail), params: { detail: { acc: @detail.acc, acc_virtual: @detail.acc_virtual, alert_email: @detail.alert_email, alert_telegram: @detail.alert_telegram, alert_whatsApp: @detail.alert_whatsApp, apn: @detail.apn, bat_bck: @detail.bat_bck, bat_nivel: @detail.bat_nivel, battery: @detail.battery, cercas: @detail.cercas, charge: @detail.charge, created_at: @detail.created_at, device_id: @detail.device_id, device_name: @detail.device_name, heartbeat: @detail.heartbeat, horimetro: @detail.horimetro, ignition: @detail.ignition, imei: @detail.imei, ip_and_port: @detail.ip_and_port, last_event_type: @detail.last_event_type, model: @detail.model, network: @detail.network, obs: @detail.obs, odometro: @detail.odometro, params: @detail.params, rele_state: @detail.rele_state, satelites: @detail.satelites, send_battery: @detail.send_battery, send_exit_cerca: @detail.send_exit_cerca, send_rele: @detail.send_rele, send_velo_max: @detail.send_velo_max, signal_gps: @detail.signal_gps, signal_gsm: @detail.signal_gsm, status: @detail.status, updated_at: @detail.updated_at, url: @detail.url, velo_max: @detail.velo_max, version: @detail.version } }
    assert_redirected_to admin_detail_url(@detail)
  end

  test "should destroy detail" do
    assert_difference("Detail.count", -1) do
      delete admin_detail_url(@detail)
    end

    assert_redirected_to admin_details_url
  end
end
