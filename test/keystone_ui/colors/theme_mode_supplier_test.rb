# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::ThemeModeSupplierTest < ActiveSupport::TestCase
  test "supplies keystone_ui with the theme mode the view knows" do
    view = Struct.new(:keystone_theme_mode).new("dark")

    assert_equal "dark", KeystoneUi.configuration.supplied_theme_mode(view)
  end
end
