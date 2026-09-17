# frozen_string_literal: true

require "test_helper"

class PickerPartialTest < ActionView::TestCase
  include KeystoneUiHelper

  test "the picker submits to the address it is given" do
    user = User.create!(name: "Test")
    preference = KeystoneUi::Colors::ThemePreference.new(owner: user, accent: "blue", surface: "slate")

    render partial: "keystone_ui/colors/settings/picker", locals: { preference: preference, url: "/somewhere/else" }

    assert_includes rendered, 'action="/somewhere/else"'
  end
end
