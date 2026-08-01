# frozen_string_literal: true

module KeystoneUi
  module Colors
    class Engine < ::Rails::Engine
      isolate_namespace KeystoneUi::Colors

      initializer "keystone_ui.colors.url_helpers" do
        ActiveSupport.on_load(:action_controller) do
          helper Rails.application.routes.url_helpers
        end
      end
    end
  end
end
