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
        Templates[@template_name][:background]
      end
    end
  end
end
