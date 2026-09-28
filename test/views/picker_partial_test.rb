# frozen_string_literal: true

require "test_helper"

class PickerPartialTest < ActionView::TestCase
  include KeystoneUiHelper

  def teardown
    KeystoneUi::Colors.reset_configuration!
  end

  test "a member's picker offers no look when their account keeps the look" do
    account = Account.create!(name: "Acme")
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone", members_choose_look: false)

    render partial: "keystone_ui/colors/settings/picker", locals: { person: User.create!(name: "Member"), account: account, submit_url: "/colors" }

    assert_select ".ks-section-title", text: "Look", count: 0
  end
end
