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
end
