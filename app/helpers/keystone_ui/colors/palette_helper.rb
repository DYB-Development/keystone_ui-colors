# frozen_string_literal: true

module KeystoneUi
  module Colors
    module PaletteHelper
      def keystone_palette_style_tag
        css = keystone_palette_css
        return unless css

        content_tag(:style, css)
      end
    end
  end
end
