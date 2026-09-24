# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::ConfigurationTest < ActiveSupport::TestCase
  def teardown
    KeystoneUi::Colors.reset_configuration!
  end

  test "has sensible defaults" do
    config = KeystoneUi::Colors.configuration

    assert_equal :current_user, config.current_owner_method
    assert_equal :authenticate_user!, config.authentication_method
    assert_equal :ocean, config.default_template
    assert_equal "blue", config.default_accent
    assert_equal "zinc", config.default_surface
    assert_equal "application", config.layout
  end

  test "defaults the theme mode to light" do
    assert_equal "light", KeystoneUi::Colors::Configuration.new.default_mode
  end

  test "defaults a custom page's background to #ffffff" do
    assert_equal "#ffffff", KeystoneUi::Colors::Configuration.new.default_background
  end

  test "defaults a custom page's text to #18181b" do
    assert_equal "#18181b", KeystoneUi::Colors::Configuration.new.default_text
  end

  test "lets account owners choose their account's colours by default" do
    assert_equal true, KeystoneUi::Colors::Configuration.new.account_colors
  end

  test "names no current account method by default" do
    assert_equal nil, KeystoneUi::Colors::Configuration.new.current_account_method
  end
end
