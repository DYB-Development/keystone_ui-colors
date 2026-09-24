# frozen_string_literal: true

module KeystoneUi
  module Colors
    class CustomColours
      def initialize(template_name:, surface:, text:)
        @template_name = template_name
        @surface = surface
        @text = text
      end

      def background
        return Templates[@template_name][:background] if @template_name.present?
        return @surface if @surface&.start_with?("#")

        KeystoneUi::Colors.configuration.default_background
      end

      def text
        return Templates[@template_name][:text] if @template_name.present?

        @text.presence || KeystoneUi::Colors.configuration.default_text
      end
    end
  end
end
