# frozen_string_literal: true

require "test_helper"
require "rails/generators"
require "generators/keystone_ui/colors/install/install_generator"

class KeystoneUi::Colors::Generators::InstallGeneratorTest < ActiveSupport::TestCase
  def destination
    @destination ||= File.expand_path("../../tmp/generator_test", __dir__)
  end

  def setup
    FileUtils.mkdir_p(destination)
    Rails::Generators.invoke("keystone_ui:colors:install", [], destination_root: destination, quiet: true)
  end

  def teardown
    FileUtils.rm_rf(destination)
  end

  test "copies the create_theme_preferences migration" do
    migration_files = Dir.glob("#{destination}/db/migrate/*_create_keystone_ui_colors_theme_preferences.rb")

    assert_equal 1, migration_files.length
    content = File.read(migration_files.first)
    assert_includes content, "create_table :keystone_ui_colors_theme_preferences"
  end

  test "prints setup instructions" do
    output = capture_stdout do
      Rails::Generators.invoke("keystone_ui:colors:install", [], destination_root: destination, skip: true)
    end

    assert_includes output, "mount KeystoneUi::Colors::Engine"
    assert_includes output, "rails db:migrate"
    assert_includes output, "keystone_palette_style_tag"
  end

  private

  def capture_stdout
    old = $stdout
    captured = StringIO.new
    $stdout = captured
    yield
    captured.string
  ensure
    $stdout = old
  end
end
