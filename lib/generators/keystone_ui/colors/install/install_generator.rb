# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module KeystoneUi
  module Colors
    module Generators
      class InstallGenerator < Rails::Generators::Base
        include ActiveRecord::Generators::Migration

        source_root File.expand_path("templates", __dir__)

        desc "Installs KeystoneUi::Colors: copies migration and prints setup instructions."

        def copy_migration
          migration_template(
            "create_keystone_ui_colors_theme_preferences.rb.erb",
            "db/migrate/create_keystone_ui_colors_theme_preferences.rb"
          )
        end

        def copy_stimulus_controller
          js_source = File.expand_path("../../../../../app/javascript/keystone_ui/colors/theme_settings_controller.js", __dir__)
          create_file "app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js", File.read(js_source)
        end

        def show_instructions
          say ""
          say "KeystoneUi::Colors installed! Next steps:", :green
          say ""
          say "  1. Run migrations:"
          say "       rails db:migrate"
          say ""
          say "  2. Mount the engine in config/routes.rb:"
          say "       mount KeystoneUi::Colors::Engine => '/keystone_ui_colors'"
          say ""
          say "  3. Include the concern in your ApplicationController:"
          say "       include KeystoneUi::Colors::CurrentPalette"
          say "       before_action :set_current_palette"
          say ""
          say "  4. Add the style tag to your layout <head>:"
          say "       <%= keystone_palette_style_tag %>"
          say ""
        end
      end
    end
  end
end
