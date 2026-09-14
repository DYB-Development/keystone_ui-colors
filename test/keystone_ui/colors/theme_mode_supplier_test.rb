# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::ThemeModeSupplierTest < ActiveSupport::TestCase
  test "supplies keystone_ui with the theme mode the view knows" do
    view = Struct.new(:keystone_theme_mode).new("dark")

    assert_equal "dark", KeystoneUi.configuration.supplied_theme_mode(view)
  end

  test "supplies the configured default theme mode for a view that does not know one" do
    assert_equal "light", KeystoneUi.configuration.supplied_theme_mode(Object.new)
  end
end
