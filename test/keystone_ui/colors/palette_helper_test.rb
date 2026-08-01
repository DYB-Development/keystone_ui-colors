# frozen_string_literal: true

require "test_helper"
require "action_view"
require_relative "../../../app/helpers/keystone_ui/colors/palette_helper"

class KeystoneUi::Colors::PaletteHelperTest < ActiveSupport::TestCase
  def helper
    @helper ||= Class.new {
      include ActionView::Helpers::TagHelper
      include KeystoneUi::Colors::PaletteHelper

      attr_accessor :keystone_palette_css, :output_buffer
    }.new
  end

  test "returns a style tag with CSS variables using content_tag" do
    helper.keystone_palette_css = ":root {\n  --color-accent-500: #3b82f6;\n}"

    result = helper.keystone_palette_style_tag
    assert_includes result, "<style>"
    assert_includes result, "--color-accent-500: #3b82f6"
    assert_includes result, "</style>"
    assert result.html_safe?
  end

  test "returns nil when no palette is set" do
    helper.keystone_palette_css = nil

    assert_nil helper.keystone_palette_style_tag
  end
end
