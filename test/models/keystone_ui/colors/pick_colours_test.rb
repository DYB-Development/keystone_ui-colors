# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::PickColoursTest < ActiveSupport::TestCase
  test "an object built with the person keeps the colours on that person" do
    user = User.create!(name: "Test")

    KeystoneUi::Colors::PickColours.new(person: user, account: :an_account, values: { template_name: "ocean" }).call

    assert_equal KeystoneUi::Colors::Templates[:ocean][:accent].to_s, KeystoneUi::Colors::ThemePreference.find_by(owner: user).accent
  end

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

  test "a host still building it with the owner keeps working" do
    user = User.create!(name: "Test")

    KeystoneUi::Colors::PickColours.new(owner: user, values: { template_name: "forest" }).call

    assert_equal KeystoneUi::Colors::Templates[:forest][:accent].to_s, KeystoneUi::Colors::ThemePreference.find_by(owner: user).accent
  end

  test "keeps a picked text colour with custom colours" do
    user = User.create!(name: "Test")

    KeystoneUi::Colors::PickColours.new(person: user, values: { accent: "#e11d48", surface: "#f5e6c8", text: "#3b2f1e" }).call

    assert_equal "#3b2f1e", KeystoneUi::Colors::ThemePreference.find_by(owner: user).text
  end

  test "picking custom colours forgets a preset theme chosen earlier" do
    user = User.create!(name: "Test")
    KeystoneUi::Colors::PickColours.new(person: user, values: { template_name: "ocean" }).call

    KeystoneUi::Colors::PickColours.new(person: user, values: { template_name: "", accent: "#d52929", surface: "#2020c4" }).call

    assert_nil KeystoneUi::Colors::ThemePreference.find_by(owner: user).template_name
  end

  test "keeps only the mode from a person whose account keeps the colour choice" do
    user = User.create!(name: "Member")
    account = Account.create!(name: "Acme")
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", members_choose: false)

    KeystoneUi::Colors::PickColours.new(person: user, account: account, values: { template_name: "", accent: "#e11d48", surface: "#f5e6c8", mode: "dark" }).call

    kept = KeystoneUi::Colors::ThemePreference.find_by(owner: user)
    assert_equal [ "dark", KeystoneUi::Colors.configuration.default_accent ], [ kept.mode, kept.accent ]
  end
end
