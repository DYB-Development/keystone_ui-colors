# frozen_string_literal: true

require "rails/generators"

module KeystoneUi
  module Colors
    module Generators
      class UpdateGenerator < Rails::Generators::Base
        source_root File.expand_path("../../../../../app/javascript/keystone_ui/colors", __dir__)

        desc "Updates KeystoneUi::Colors assets (Stimulus controller)."

        def copy_stimulus_controller
          copy_file "theme_settings_controller.js",
            "app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js"
        end
      end
    end
  end
end
