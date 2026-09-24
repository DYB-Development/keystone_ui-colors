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
end
