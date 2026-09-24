# frozen_string_literal: true

module KeystoneUi
  module Colors
    class ColourChoice
      def initialize(person:, account:)
        @person = person
        @account = account
      end

      def person_chooses?
        account_preference.nil? || account_preference.members_choose
      end

      private

      def account_preference
        return nil unless @account

        @account_preference ||= ThemePreference.find_by(owner: @account)
      end
    end
  end
end
