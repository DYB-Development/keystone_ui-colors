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

  test "a named surface palette leaves the configured background when no preset theme is chosen" do
    colours = KeystoneUi::Colors::CustomColours.new(template_name: nil, surface: "stone", text: nil)

    assert_equal KeystoneUi::Colors.configuration.default_background, colours.background
  end

  test "a preset theme supplies the text colour" do
    colours = KeystoneUi::Colors::CustomColours.new(template_name: "twilight", surface: "zinc", text: nil)

    assert_equal KeystoneUi::Colors::Templates[:twilight][:text], colours.text
  end

  test "a picked text colour is used when no preset theme is chosen" do
    colours = KeystoneUi::Colors::CustomColours.new(template_name: "", surface: "#f5e6c8", text: "#3b2f1e")

    assert_equal "#3b2f1e", colours.text
  end
end
