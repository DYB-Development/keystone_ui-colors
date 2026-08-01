# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::TemplatesTest < ActiveSupport::TestCase
  SUPPORTED_ACCENTS = %w[blue emerald cyan indigo violet rose].flat_map { |c| [ c, c.to_sym ] }.freeze
  SUPPORTED_SURFACES = %w[zinc slate gray neutral stone].flat_map { |c| [ c, c.to_sym ] }.freeze

  test "provides exactly 6 preset templates" do
    assert_equal 6, KeystoneUi::Colors::Templates.names.size
  end

  test "exposes all template names" do
    assert_equal [ :default, :ocean, :forest, :twilight, :coral, :arctic ].sort,
                 KeystoneUi::Colors::Templates.names.sort
  end

  KeystoneUi::Colors::Templates.all.each do |name, template|
    define_method("test_template_#{name}_uses_a_supported_accent") do
      assert_includes SUPPORTED_ACCENTS, template[:accent]
    end

    define_method("test_template_#{name}_uses_a_supported_surface") do
      assert_includes SUPPORTED_SURFACES, template[:surface]
    end

    define_method("test_template_#{name}_has_label_and_description") do
      assert_kind_of String, template[:label]
      assert_kind_of String, template[:description]
    end
  end

  test "returns a template by name" do
    ocean = KeystoneUi::Colors::Templates[:ocean]
    assert_equal :blue, ocean[:accent]
    assert_equal :slate, ocean[:surface]
  end

  test "raises KeyError for unknown template" do
    assert_raises(KeyError) { KeystoneUi::Colors::Templates[:nonexistent] }
  end

  test "default template uses configured default_accent and default_surface" do
    KeystoneUi::Colors.configuration.default_accent = "indigo"
    KeystoneUi::Colors.configuration.default_surface = "slate"

    default = KeystoneUi::Colors::Templates[:default]
    assert_equal "indigo", default[:accent]
    assert_equal "slate", default[:surface]
  ensure
    KeystoneUi::Colors.reset_configuration!
  end

  test "uses distinct accent/surface combinations" do
    combos = KeystoneUi::Colors::Templates.all.values.map { |t| [ t[:accent], t[:surface] ] }
    assert_equal combos.size, combos.uniq.size
  end
end
