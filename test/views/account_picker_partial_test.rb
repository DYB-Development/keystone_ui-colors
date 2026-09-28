# frozen_string_literal: true

require "test_helper"

class AccountPickerPartialTest < ActionView::TestCase
  include KeystoneUiHelper

  def render_picker
    render partial: "keystone_ui/colors/settings/account_picker",
      locals: { person: User.create!(name: "Owner"), account: Account.create!(name: "Acme"), submit_url: "/account/colors" }
  end

  test "the account picker offers the preset themes" do
    render_picker

    assert_includes rendered, 'value="ocean"'
  end

  test "the account picker lets members choose their own colours by default" do
    render_picker

    assert_select "input[type='checkbox'][name='members_choose'][value='1'][checked]"
  end

  test "the account picker offers every registered look with the account's look chosen" do
    account = Account.create!(name: "Acme")
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", look: "material")

    render partial: "keystone_ui/colors/settings/account_picker", locals: { person: User.create!(name: "Owner"), account: account, submit_url: "/account/colors" }

    assert_select "input[name='look'][value='plain']"
    assert_select "input[name='look'][value='material'][checked]"
  end

  test "the account picker offers no look when the host lets accounts choose none" do
    KeystoneUi::Colors.configuration.account_looks = false

    render_picker

    assert_select ".ks-section-title", text: "Look", count: 0
  ensure
    KeystoneUi::Colors.reset_configuration!
  end
end
