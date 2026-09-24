# frozen_string_literal: true

module KeystoneUi
  module Colors
    class PickAccountColours
      def initialize(values:, person: nil, account: nil)
        @account = account
        @values = values
      end

      def call
        PickColours.new(owner: @account, values: @values).call
      end
    end
  end
end
