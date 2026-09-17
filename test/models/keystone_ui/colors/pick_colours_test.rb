# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::PickColoursTest < ActiveSupport::TestCase
  test "picking a preset keeps that preset's accent on the person" do
    user = User.create!(name: "Test")

    KeystoneUi::Colors::PickColours.new(owner: user, values: { template_name: "ocean" }).call

    assert_equal KeystoneUi::Colors::Templates[:ocean][:accent].to_s, KeystoneUi::Colors::ThemePreference.find_by(owner: user).accent
  end
end
