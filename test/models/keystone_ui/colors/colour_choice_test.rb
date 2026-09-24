# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::ColourChoiceTest < ActiveSupport::TestCase
  def teardown
    KeystoneUi::Colors.reset_configuration!
  end

  def person
    @person ||= User.create!(name: "Member")
  end

  def account
    @account ||= Account.create!(name: "Acme")
  end

  test "a person chooses their own colours when nothing stops them" do
    assert KeystoneUi::Colors::ColourChoice.new(person: person, account: account).person_chooses?
  end

  test "a person does not choose their own colours when their account keeps the choice" do
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", members_choose: false)

    refute KeystoneUi::Colors::ColourChoice.new(person: person, account: account).person_chooses?
  end

  test "a person does not choose their own colours when the app does not let accounts choose" do
    KeystoneUi::Colors.configuration.account_colors = false

    refute KeystoneUi::Colors::ColourChoice.new(person: person, account: nil).person_chooses?
  end

  test "a person's own colours apply when they choose" do
    own = KeystoneUi::Colors::ThemePreference.create!(owner: person, accent: "rose", surface: "zinc")

    assert_equal own, KeystoneUi::Colors::ColourChoice.new(person: person, account: account).applying_preference
  end

  test "the account's colours apply when the account keeps the choice" do
    account_colours = KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", members_choose: false)
    KeystoneUi::Colors::ThemePreference.create!(owner: person, accent: "rose", surface: "zinc")

    assert_equal account_colours, KeystoneUi::Colors::ColourChoice.new(person: person, account: account).applying_preference
  end

  test "no saved colours apply when the app does not let accounts choose" do
    KeystoneUi::Colors.configuration.account_colors = false
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone")

    assert_nil KeystoneUi::Colors::ColourChoice.new(person: person, account: account).applying_preference
  end
end
