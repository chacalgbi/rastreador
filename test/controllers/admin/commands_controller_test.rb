require "test_helper"

class Admin::CommandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = sign_in_admin_as admin_users(:lazaro_nixon)
    @command = commands(:one)
  end

  test "should get index" do
    get admin_commands_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_command_url
    assert_response :success
  end

  test "should create command" do
    assert_difference("Command.count") do
      post admin_commands_url, params: { command: { command: @command.command, created_at: @command.created_at, description: @command.description, id: @command.id, name: @command.name, type: @command.type, updated_at: @command.updated_at } }
    end

    assert_redirected_to admin_command_url(Command.last)
  end

  test "should show command" do
    get admin_command_url(@command)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_command_url(@command)
    assert_response :success
  end

  test "should update command" do
    patch admin_command_url(@command), params: { command: { command: @command.command, created_at: @command.created_at, description: @command.description, id: @command.id, name: @command.name, type: @command.type, updated_at: @command.updated_at } }
    assert_redirected_to admin_command_url(@command)
  end

  test "should destroy command" do
    assert_difference("Command.count", -1) do
      delete admin_command_url(@command)
    end

    assert_redirected_to admin_commands_url
  end
end
