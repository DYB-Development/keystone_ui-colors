# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::PalettesTest < ActiveSupport::TestCase
  test "returns hex shades for a known accent color" do
    shades = KeystoneUi::Colors::Palettes.accent(:blue)

    assert_equal "#3b82f6", shades[500]
    assert_equal "#2563eb", shades[600]
  end

  test "returns hex shades for a known surface color" do
    shades = KeystoneUi::Colors::Palettes.surface(:zinc)

    assert_equal "#71717a", shades[500]
    assert_equal "#3f3f46", shades[700]
  end

  test "raises for unknown accent" do
    assert_raises(KeyError) { KeystoneUi::Colors::Palettes.accent(:nope) }
  end

  test "raises for unknown surface" do
    assert_raises(KeyError) { KeystoneUi::Colors::Palettes.surface(:nope) }
  end

  test "includes shade 950 for accent palettes" do
    shades = KeystoneUi::Colors::Palettes.accent(:blue)

    assert_kind_of String, shades[950]
    assert_match(/\A#[0-9a-f]{6}\z/, shades[950])
  end

  test "generate_shades generates 11 shades including 950 from a hex color" do
    shades = KeystoneUi::Colors::Palettes.generate_shades("#3b82f6")

    assert_equal [ 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950 ], shades.keys
    assert_equal "#3b82f6", shades[500]
    shades.each_value { |hex| assert_match(/\A#[0-9a-f]{6}\z/, hex) }
  end
end
