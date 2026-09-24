# frozen_string_literal: true

require "test_helper"

class PickerPartialTest < ActionView::TestCase
  include KeystoneUiHelper

  test "the picker submits to the address it is given" do
    user = User.create!(name: "Test")
    render partial: "keystone_ui/colors/settings/picker", locals: { person: user, account: nil, submit_url: "/somewhere/else" }

    assert_includes rendered, 'action="/somewhere/else"'
  end

  test "the picker offers a text colour" do
    user = User.create!(name: "Test")
    render partial: "keystone_ui/colors/settings/picker", locals: { person: user, account: nil, submit_url: "/colors" }

    assert_includes rendered, 'name="text"'
  end

  test "the picker offers no colours to a person whose account keeps the choice" do
    user = User.create!(name: "Member")
    account = Account.create!(name: "Acme")
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", members_choose: false)

    render partial: "keystone_ui/colors/settings/picker", locals: { person: user, account: account, submit_url: "/colors" }

    refute_includes rendered, 'name="accent"'
  end
end
