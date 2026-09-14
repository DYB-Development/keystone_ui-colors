# frozen_string_literal: true

require "test_helper"
require "rails/generators"
require "generators/keystone_ui/colors/update/update_generator"

class KeystoneUi::Colors::Generators::UpdateGeneratorTest < ActiveSupport::TestCase
  def destination
    @destination ||= File.expand_path("../../tmp/generator_test", __dir__)
  end

  def setup
    FileUtils.mkdir_p(destination)
  end

  def teardown
    FileUtils.rm_rf(destination)
  end

  test "copies the Stimulus controller" do
    Rails::Generators.invoke("keystone_ui:colors:update", [], destination_root: destination, quiet: true)

    js_path = "#{destination}/app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js"
    assert File.exist?(js_path)
    assert_includes File.read(js_path), "@hotwired/stimulus"
  end

  test "adds a migration giving existing preferences a theme mode" do
    Rails::Generators.invoke("keystone_ui:colors:update", [], destination_root: destination, quiet: true)

    migration = Dir.glob("#{destination}/db/migrate/*_add_mode_to_keystone_ui_colors_theme_preferences.rb").first
    assert_includes File.read(migration.to_s), "add_column :keystone_ui_colors_theme_preferences, :mode, :string"
  end
end
