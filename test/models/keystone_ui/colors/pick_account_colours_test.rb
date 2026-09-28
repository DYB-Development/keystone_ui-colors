# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::PickAccountColoursTest < ActiveSupport::TestCase
  def teardown
    KeystoneUi::Colors.reset_configuration!
  end

  def owner
    @owner ||= User.create!(name: "Owner")
  end

  def account
    @account ||= Account.create!(name: "Acme")
  end

  def pick(values)
    KeystoneUi::Colors::PickAccountColours.new(person: owner, account: account, values: values).call
  end

  def account_preference
    KeystoneUi::Colors::ThemePreference.find_by(owner: account)
  end

  test "keeps a preset theme as the account's colours" do
    pick(template_name: "forest")

    assert_equal "forest", account_preference.template_name
  end

  test "keeps whether the account lets its members choose their own colours" do
    pick(template_name: "forest", members_choose: "0")

    refute account_preference.members_choose
  end

  test "keeps no mode for the account" do
    pick(template_name: "forest", mode: "dark")

    assert_nil account_preference.mode
  end

  test "refuses when the app does not let accounts choose their colours" do
    KeystoneUi::Colors.configuration.account_colors = false

    refute pick(template_name: "forest").ok?
  end

  test "picking a look keeps it on the account" do
    pick(accent: "emerald", surface: "stone", look: "material")

    assert_equal "material", account_preference.look
  end

  test "a look in an account save is ignored when the host lets accounts choose none" do
    KeystoneUi::Colors.configuration.account_looks = false

    pick(accent: "emerald", surface: "stone", look: "material")

    assert_nil account_preference.look
  end

  test "an account can stop its members choosing their own look" do
    pick(accent: "emerald", surface: "stone", members_choose_look: "0")

    refute account_preference.members_choose_look
  end

  test "picking App default clears the account's look" do
    pick(accent: "emerald", surface: "stone", look: "material")

    pick(accent: "emerald", surface: "stone", look: "")

    assert_nil account_preference.look
  end
end
