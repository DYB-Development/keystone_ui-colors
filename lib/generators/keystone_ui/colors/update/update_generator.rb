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
          return if column_migrated?(:mode)

          migration_template(
            File.expand_path("templates/add_mode_to_keystone_ui_colors_theme_preferences.rb.erb", __dir__),
            "db/migrate/add_mode_to_keystone_ui_colors_theme_preferences.rb"
          )
        end

        def add_text_migration
          return if column_migrated?(:text)

          migration_template(
            File.expand_path("templates/add_text_to_keystone_ui_colors_theme_preferences.rb.erb", __dir__),
            "db/migrate/add_text_to_keystone_ui_colors_theme_preferences.rb"
          )
        end

        def add_members_choose_migration
          return if column_migrated?(:members_choose)

          migration_template(
            File.expand_path("templates/add_members_choose_to_keystone_ui_colors_theme_preferences.rb.erb", __dir__),
            "db/migrate/add_members_choose_to_keystone_ui_colors_theme_preferences.rb"
          )
        end

        def copy_stimulus_controller
          copy_file "theme_settings_controller.js",
            "app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js"
        end

        private

        def column_migrated?(column)
          Dir[File.join(destination_root, "db/migrate/*.rb")].any? do |migration|
            File.read(migration).match?(/t\.\w+ :#{column}\b/)
          end
        end
      end
    end
  end
end
