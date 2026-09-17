# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::PickColoursTest < ActiveSupport::TestCase
  test "picking a preset keeps that preset's accent on the person" do
    user = User.create!(name: "Test")

    KeystoneUi::Colors::PickColours.new(owner: user, values: { template_name: "ocean" }).call

    assert_equal KeystoneUi::Colors::Templates[:ocean][:accent].to_s, KeystoneUi::Colors::ThemePreference.find_by(owner: user).accent
  end

  test "a colour that is not allowed refuses and changes nothing" do
    user = User.create!(name: "Test")
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "slate")

    result = KeystoneUi::Colors::PickColours.new(owner: user, values: { accent: "neon", surface: "slate" }).call

    assert_not result.ok?
  end

  test "a colour that is not allowed leaves the colours a person had" do
    user = User.create!(name: "Test")
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "slate")

    KeystoneUi::Colors::PickColours.new(owner: user, values: { accent: "neon", surface: "slate" }).call

    assert_equal "blue", KeystoneUi::Colors::ThemePreference.find_by(owner: user).accent
  end
end
