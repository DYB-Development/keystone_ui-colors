# frozen_string_literal: true

module KeystoneUi
  module Colors
    class Engine < ::Rails::Engine
      isolate_namespace KeystoneUi::Colors

      initializer "keystone_ui.colors.theme_mode" do
        KeystoneUi.configure do |config|
          config.theme_mode_supplier = ->(view) { view.keystone_theme_mode }
        end
      end

      initializer "keystone_ui.colors.url_helpers" do
        ActiveSupport.on_load(:action_controller) do
          helper Rails.application.routes.url_helpers
        end
      end
    end
  end
end
