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
    KeystoneUi::Colors::ApplicationController.allow_forgery_protection = false
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

  test "a look saved on the settings page marks the next page" do
    patch "/keystone_ui_colors", params: { accent: "blue", surface: "zinc", look: "material" }

    get "/keystone_ui_colors"

    assert_select "html[data-look='material']"
  end

  test "the settings page offers every registered look with the user's look chosen" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "zinc", look: "material")

    get "/keystone_ui_colors"

    assert_select "input[name='look'][value='plain']"
    assert_select "input[name='look'][value='material'][checked]"
  end
end
