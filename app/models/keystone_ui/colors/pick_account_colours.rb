# frozen_string_literal: true

module KeystoneUi
  module Colors
    class PickAccountColours
      def initialize(values:, person: nil, account: nil)
        @account = account
        @values = values
      end

      def call
        return Refusal.new("This app does not let accounts choose their colours.") unless KeystoneUi::Colors.configuration.account_colors

        result = PickColours.new(owner: @account, values: @values.except(:members_choose, :members_choose_look, :mode), look_allowed: KeystoneUi::Colors.configuration.account_looks).call
        return result unless result.ok?

        switches = @values.slice(:members_choose, :members_choose_look).transform_values { |value| value == "1" }
        ThemePreference.find_by(owner: @account).update!(switches) if switches.any?
        result
      end
    end
  end
end
