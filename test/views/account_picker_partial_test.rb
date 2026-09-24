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
end
