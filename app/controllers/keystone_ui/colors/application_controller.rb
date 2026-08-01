# frozen_string_literal: true

module KeystoneUi
  module Colors
    class ApplicationController < ::ApplicationController
      before_action { send(KeystoneUi::Colors.configuration.authentication_method) }
      helper KeystoneUiHelper

      layout -> { KeystoneUi::Colors.configuration.layout }
    end
  end
end
