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
end
