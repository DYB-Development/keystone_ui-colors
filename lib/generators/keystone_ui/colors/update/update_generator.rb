# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module KeystoneUi
  module Colors
    module Generators
      class UpdateGenerator < Rails::Generators::Base
        include ActiveRecord::Generators::Migration

        source_root File.expand_path("../../../../../app/javascript/keystone_ui/colors", __dir__)

        desc "Updates KeystoneUi::Colors: copies the Stimulus controller and adds new migrations."

        def add_mode_migration
          migration_template(
            File.expand_path("templates/add_mode_to_keystone_ui_colors_theme_preferences.rb.erb", __dir__),
            "db/migrate/add_mode_to_keystone_ui_colors_theme_preferences.rb"
          )
        end

        def copy_stimulus_controller
          copy_file "theme_settings_controller.js",
            "app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js"
        end
      end
    end
  end
end
