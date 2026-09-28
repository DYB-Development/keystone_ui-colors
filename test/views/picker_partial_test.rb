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

  test "the picker leaves out the custom mode when the account's colours draw white" do
    user = User.create!(name: "Member")
    account = Account.create!(name: "Acme")
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", members_choose: false)

    render partial: "keystone_ui/colors/settings/picker", locals: { person: user, account: account, submit_url: "/colors" }

    refute_includes rendered, 'value="custom"'
  end

  test "the picker offers the custom mode when the account's preset draws a background" do
    user = User.create!(name: "Member")
    account = Account.create!(name: "Acme")
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "blue", surface: "slate", template_name: "ocean", members_choose: false)

    render partial: "keystone_ui/colors/settings/picker", locals: { person: user, account: account, submit_url: "/colors" }

    assert_includes rendered, 'value="custom"'
  end

  test "a member's picker offers no look when their account keeps the look" do
    account = Account.create!(name: "Acme")
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", members_choose_look: false)

    render partial: "keystone_ui/colors/settings/picker", locals: { person: User.create!(name: "Member"), account: account, submit_url: "/colors" }

    assert_select ".ks-section-title", text: "Look", count: 0
  end

  test "the picker offers App default ahead of the registered looks" do
    render partial: "keystone_ui/colors/settings/picker", locals: { person: User.create!(name: "Test"), account: nil, submit_url: "/colors" }

    assert_equal "", css_select("input[name='look']").first["value"]
  end

  test "the picker chooses App default when no look is saved" do
    render partial: "keystone_ui/colors/settings/picker", locals: { person: User.create!(name: "Test"), account: nil, submit_url: "/colors" }

    assert_select "input[name='look'][value=''][checked]"
  end
end
