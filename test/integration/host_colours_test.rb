# frozen_string_literal: true

require "test_helper"

class HostColoursTest < ActionDispatch::IntegrationTest
  def user
    @user ||= User.create!(name: "Test")
  end

  def setup
    uid = user.id
    ApplicationController.define_method(:current_user) { User.find(uid) }
  end

  def teardown
    ApplicationController.remove_method(:current_user) rescue nil
  end

  test "a page kept on the host's colours ignores the mode a user saved" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "emerald", surface: "stone", mode: "dark")

    get "/"

    assert_select "html[data-theme='light']"
  end
end
