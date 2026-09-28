# frozen_string_literal: true

require "test_helper"

class LooksTest < ActionDispatch::IntegrationTest
  def user
    @user ||= User.create!(name: "Test")
  end

  def setup
    uid = user.id
    KeystoneUi::Colors::ApplicationController.define_method(:current_user) { User.find(uid) }
    KeystoneUi::Colors::ApplicationController.define_method(:authenticate_user!) { true }
  end

  def teardown
    KeystoneUi::Colors::ApplicationController.remove_method(:current_user) rescue nil
    KeystoneUi::Colors::ApplicationController.remove_method(:authenticate_user!) rescue nil
  end

  test "a user's saved look marks every page" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "zinc", look: "material")

    get "/keystone_ui_colors"

    assert_select "html[data-look='material']"
  end
end
