# frozen_string_literal: true

require "application_system_test_case"

class ColorSettingsTest < ApplicationSystemTestCase
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

  test "selects a theme preset and saves" do
    visit "/keystone_ui_colors"

    choose("theme_preference[template_name]", option: "forest")
    click_button "Save"

    assert_text "Color settings updated."
    pref = user.reload.theme_preference
    assert_equal "emerald", pref.accent
    assert_equal "stone", pref.surface
    assert_equal "forest", pref.template_name
  end

  test "selects the default theme preset and saves" do
    visit "/keystone_ui_colors"

    choose("theme_preference[template_name]", option: "default")
    click_button "Save"

    pref = user.reload.theme_preference
    assert_equal "blue", pref.accent
    assert_equal "zinc", pref.surface
    assert_equal "default", pref.template_name
  end

  test "renders color picker components" do
    visit "/keystone_ui_colors"

    assert_css "[data-controller='color-picker']", count: 2
  end

  test "a signed-in user's saved theme mode marks the page" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "zinc", mode: "dark")

    visit "/keystone_ui_colors"

    assert_selector :xpath, "/html[@data-theme='dark']", visible: :all
  end
end
