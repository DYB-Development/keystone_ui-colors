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

  test "a user with no saved look sees the host's default look" do
    get "/keystone_ui_colors"

    assert_select "html[data-look='plain']"
  end

  test "a visitor who is not signed in sees the host's default look" do
    KeystoneUi::Colors::ApplicationController.define_method(:current_user) { nil }

    get "/keystone_ui_colors"

    assert_select "html[data-look='plain']"
  end

  test "a user whose look changes sees the new look on the next page" do
    preference = KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "zinc", look: "plain")
    get "/keystone_ui_colors"

    preference.update!(look: "material", updated_at: 1.minute.from_now)
    get "/keystone_ui_colors"

    assert_select "html[data-look='material']"
  end
end
