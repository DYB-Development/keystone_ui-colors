# frozen_string_literal: true

module KeystoneUi
  module Colors
    class ColourChoice
      def initialize(person:, account:)
        @person = person
        @account = account
      end

      def person_chooses?
        return false unless KeystoneUi::Colors.configuration.account_colors

        account_preference.nil? || account_preference.members_choose
      end

      def applying_preference
        return nil unless KeystoneUi::Colors.configuration.account_colors
        return own_preference || account_preference if person_chooses?

        account_preference
      end

      def custom_offered?
        preference = applying_preference
        CustomColours.new(template_name: preference&.template_name, surface: preference&.surface, text: preference&.text).background
      end

      private

      def own_preference
        @own_preference ||= ThemePreference.find_by(owner: @person)
      end

      def account_preference
        return nil unless @account

        @account_preference ||= ThemePreference.find_by(owner: @account)
      end
    end
  end
end
