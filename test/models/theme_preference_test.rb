# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::ThemePreferenceTest < ActiveSupport::TestCase
  def user
    @user ||= User.create!(name: "Test")
  end

  test "belongs to a polymorphic owner" do
    pref = KeystoneUi::Colors::ThemePreference.create!(
      owner: user,
      accent: "blue",
      surface: "slate"
    )

    assert_equal user, pref.owner
    assert_equal "User", pref.owner_type
  end

  test "validates accent is a supported value" do
    pref = KeystoneUi::Colors::ThemePreference.new(owner: user, accent: "neon", surface: "slate")

    refute pref.valid?
    assert pref.errors[:accent].any? { |msg| msg =~ /must be a supported color name or hex value/ }
  end

  test "validates surface is a supported value" do
    pref = KeystoneUi::Colors::ThemePreference.new(owner: user, accent: "blue", surface: "marble")

    refute pref.valid?
    assert pref.errors[:surface].any? { |msg| msg =~ /must be a supported color name or hex value/ }
  end

  test "allows blank template_name for custom colors" do
    pref = KeystoneUi::Colors::ThemePreference.new(owner: user, accent: "#f446ee", surface: "#737373", template_name: "")

    assert pref.valid?
  end

  test "validates template_name is a known template when present" do
    pref = KeystoneUi::Colors::ThemePreference.new(owner: user, accent: "blue", surface: "slate", template_name: "unknown")

    refute pref.valid?
    assert pref.errors[:template_name].any? { |msg| msg =~ /is not included/ }
  end

  test "apply_template! sets accent and surface from a template and saves" do
    pref = KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "slate")

    pref.apply_template!(:forest)

    pref.reload
    assert_equal "emerald", pref.accent
    assert_equal "stone", pref.surface
    assert_equal "forest", pref.template_name
  end

  test "rejects a mode other than light, dark or system" do
    pref = KeystoneUi::Colors::ThemePreference.new(owner: user, accent: "blue", surface: "zinc", mode: "purple")

    refute pref.valid?
  end
end
