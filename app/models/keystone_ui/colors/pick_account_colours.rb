# frozen_string_literal: true

module KeystoneUi
  module Colors
    class PickAccountColours
      def initialize(values:, person: nil, account: nil)
        @account = account
        @values = values
      end

      def call
        result = PickColours.new(owner: @account, values: @values.except(:members_choose, :mode)).call
        return result unless result.ok? && @values.key?(:members_choose)

        ThemePreference.find_by(owner: @account).update!(members_choose: @values[:members_choose] == "1")
        result
      end
    end
  end
end
