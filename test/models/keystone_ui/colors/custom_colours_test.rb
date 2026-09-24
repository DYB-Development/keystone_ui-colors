# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::CustomColoursTest < ActiveSupport::TestCase
  test "a preset theme supplies the background" do
    colours = KeystoneUi::Colors::CustomColours.new(template_name: "forest", surface: "stone", text: nil)

    assert_equal KeystoneUi::Colors::Templates[:forest][:background], colours.background
  end

  test "a picked surface colour is the background when no preset theme is chosen" do
    colours = KeystoneUi::Colors::CustomColours.new(template_name: "", surface: "#f5e6c8", text: nil)

    assert_equal "#f5e6c8", colours.background
  end
end
