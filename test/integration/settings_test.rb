# frozen_string_literal: true

require "test_helper"

class SettingsTest < ActionDispatch::IntegrationTest
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

  test "GET /keystone_ui_colors returns a successful response" do
    get "/keystone_ui_colors"

    assert_response :ok
  end

  test "GET /keystone_ui_colors renders color pickers and theme presets" do
    get "/keystone_ui_colors"

    body = response.body
    assert_includes body, 'data-controller="color-picker"'
    assert_includes body, "Default"
    assert_includes body, "Ocean"
    assert_includes body, "Custom"
  end

  test "GET /keystone_ui_colors renders selected state for current theme" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "violet", surface: "zinc", template_name: "twilight")

    get "/keystone_ui_colors"

    assert_includes response.body, "data-selected-template=\"twilight\""
  end

  test "PATCH /keystone_ui_colors creates a preference with valid accent and surface" do
    patch "/keystone_ui_colors", params: { accent: "violet", surface: "zinc" }

    assert_redirected_to "/keystone_ui_colors/"
    pref = user.reload.theme_preference
    assert_equal "violet", pref.accent
    assert_equal "zinc", pref.surface
  end

  test "PATCH /keystone_ui_colors saves custom hex colors" do
    patch "/keystone_ui_colors", params: { accent: "#e11d48", surface: "#44403c" }

    assert_redirected_to "/keystone_ui_colors/"
    pref = user.reload.theme_preference
    assert_equal "#e11d48", pref.accent
    assert_equal "#44403c", pref.surface
  end

  test "PATCH /keystone_ui_colors applies a template when template_name is provided" do
    patch "/keystone_ui_colors", params: { template_name: "forest" }

    assert_redirected_to "/keystone_ui_colors/"
    pref = user.reload.theme_preference
    assert_equal "emerald", pref.accent
    assert_equal "stone", pref.surface
    assert_equal "forest", pref.template_name
  end

  test "DELETE /keystone_ui_colors destroys the preference and redirects" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "violet", surface: "zinc")

    delete "/keystone_ui_colors"

    assert_redirected_to "/keystone_ui_colors/"
    assert_nil KeystoneUi::Colors::ThemePreference.find_by(owner: user)
  end

  test "form action uses the engine route helper for the form url" do
    get "/keystone_ui_colors"

    assert_includes response.body, 'action="/keystone_ui_colors/"'
  end

  test "rejects unauthenticated requests" do
    KeystoneUi::Colors.configure do |config|
      config.authentication_method = :reject_all!
    end

    KeystoneUi::Colors::ApplicationController.define_method(:reject_all!) do
      head :unauthorized
    end

    get "/keystone_ui_colors"

    assert_response :unauthorized

    KeystoneUi::Colors::ApplicationController.remove_method(:reject_all!)
    KeystoneUi::Colors.reset_configuration!
  end

  test "PATCH /keystone_ui_colors saves the chosen theme mode" do
    patch "/keystone_ui_colors", params: { accent: "blue", surface: "zinc", mode: "dark" }

    assert_equal "dark", user.reload.theme_preference.mode
  end

  test "PATCH /keystone_ui_colors saves the chosen theme mode along with a preset theme" do
    patch "/keystone_ui_colors", params: { template_name: "forest", mode: "system" }

    assert_equal "system", user.reload.theme_preference.mode
  end

  test "PATCH /keystone_ui_colors clears the toggle's choice in this browser" do
    cookies[KeystoneUi::ThemeChoice::COOKIE] = "dark"

    patch "/keystone_ui_colors", params: { accent: "blue", surface: "zinc", mode: "light" }

    assert_predicate cookies[KeystoneUi::ThemeChoice::COOKIE], :blank?
  end

  test "GET /keystone_ui_colors offers a dark theme mode" do
    get "/keystone_ui_colors"

    assert_select "input[type=radio][name='mode'][value=dark]"
  end

  test "GET /keystone_ui_colors selects the theme mode the user saved" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "zinc", mode: "dark")

    get "/keystone_ui_colors"

    assert_select "input[name='mode'][value=dark][checked]"
  end

  test "GET /keystone_ui_colors selects the configured default theme mode when the user saved none" do
    get "/keystone_ui_colors"

    assert_select "input[name='mode'][value=light][checked]"
  end
end
