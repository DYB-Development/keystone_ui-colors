# frozen_string_literal: true

module KeystoneUi
  module Colors
    class ColourChoice
      def initialize(person:, account:)
        @person = person
        @account = account
      end

      def person_chooses?
        true
      end
    end
  end
end
