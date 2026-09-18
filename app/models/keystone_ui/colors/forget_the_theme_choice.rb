# frozen_string_literal: true

module KeystoneUi
  module Colors
    class ForgetTheThemeChoice
      def initialize(controller:)
        @controller = controller
      end

      def call
        @controller.request.cookie_jar.delete(KeystoneUi::ThemeChoice::COOKIE)
      end
    end
  end
end
