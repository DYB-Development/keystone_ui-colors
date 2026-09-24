# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::CurrentPaletteTest < ActiveSupport::TestCase
  def controller_class
    @controller_class ||= Class.new do
      include KeystoneUi::Colors::CurrentPalette

      attr_accessor :current_user, :session

      def initialize(user:, session: {})
        @current_user = user
        @session = session
      end
    end
  end

  def user
    @user ||= User.create!(name: "Test")
  end

  test "stores accent and surface CSS variables from the owner's preference" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "emerald", surface: "stone")
    controller = controller_class.new(user: user)

    controller.set_current_palette

    css = controller.keystone_palette_css
    assert_includes css, "--color-accent-500: #10b981"
    assert_includes css, "--color-surface-700: #44403c"
  end

  test "uses configured defaults when owner has no preference" do
    controller = controller_class.new(user: user)

    controller.set_current_palette

    css = controller.keystone_palette_css
    assert_includes css, "--color-accent-500: #3b82f6"
    assert_includes css, "--color-surface-500: #71717a"
  end

  test "uses configured defaults when there is no current owner" do
    controller = controller_class.new(user: nil)

    controller.set_current_palette

    css = controller.keystone_palette_css
    assert_includes css, "--color-accent-500: #3b82f6"
    assert_includes css, "--color-surface-500: #71717a"
  end

  test "caches palette in session and skips DB on subsequent requests" do
    pref = KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "emerald", surface: "stone")
    session = {}
    controller = controller_class.new(user: user, session: session)

    controller.set_current_palette

    assert_equal({
      accent: "emerald",
      surface: "stone",
      mode: nil,
      template_name: nil,
      text: nil,
      updated_at: pref.updated_at.to_i
    }, session[:keystone_ui_colors_palette])

    # Second request must use the session cache, not DB
    controller2 = controller_class.new(user: user, session: session)
    KeystoneUi::Colors::ThemePreference.stub(:find_by, ->(*) { flunk "find_by should not be called when cached" }) do
      controller2.set_current_palette
    end

    assert_includes controller2.keystone_palette_css, "--color-accent-500: #10b981"
  end

  test "reloads from DB when session cache is stale" do
    pref = KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "emerald", surface: "stone")
    session = {
      keystone_ui_colors_palette: {
        accent: "emerald",
        surface: "stone",
        updated_at: (pref.updated_at - 1).to_i
      }
    }
    controller = controller_class.new(user: user, session: session)

    pref.update!(accent: "violet", surface: "zinc")
    controller.set_current_palette

    css = controller.keystone_palette_css
    assert_includes css, "--color-accent-500: #8b5cf6"
    assert_equal "violet", session[:keystone_ui_colors_palette][:accent]
  end

  test "builds CSS from custom hex values" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "#e11d48", surface: "#44403c")
    controller = controller_class.new(user: user)

    controller.set_current_palette

    css = controller.keystone_palette_css
    assert_includes css, "--color-accent-500: #e11d48"
    assert_includes css, "--color-surface-500: #44403c"
  end

  test "knows the theme mode the owner saved" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "zinc", mode: "dark")
    controller = controller_class.new(user: user)

    controller.set_current_palette

    assert_equal "dark", controller.keystone_theme_mode
  end

  test "uses the configured default theme mode when the owner saved none" do
    KeystoneUi::Colors.configure { |config| config.default_mode = "system" }
    controller = controller_class.new(user: user)

    controller.set_current_palette

    assert_equal "system", controller.keystone_theme_mode
  ensure
    KeystoneUi::Colors.reset_configuration!
  end

  test "uses the configured default theme mode when there is no current owner" do
    controller = controller_class.new(user: nil)

    controller.set_current_palette

    assert_equal "light", controller.keystone_theme_mode
  end

  test "knows the saved theme mode when the palette comes from the session cache" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "blue", surface: "zinc", mode: "dark")
    session = {}
    controller_class.new(user: user, session: session).set_current_palette
    cached = controller_class.new(user: user, session: session)

    cached.set_current_palette

    assert_equal "dark", cached.keystone_theme_mode
  end

  test "lets views read the theme mode" do
    helpers = []
    Class.new do
      define_singleton_method(:helper_method) { |*names| helpers.concat(names) }
      include KeystoneUi::Colors::CurrentPalette
    end

    assert_includes helpers, :keystone_theme_mode
  end

  test "writes the preset theme's background as the custom background" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "emerald", surface: "stone", template_name: "forest")
    controller = controller_class.new(user: user)

    controller.set_current_palette

    assert_includes controller.keystone_palette_css, "--color-custom-background: #{KeystoneUi::Colors::Templates[:forest][:background]}"
  end

  test "writes a picked text colour as the custom text" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "#e11d48", surface: "#f5e6c8", text: "#3b2f1e", template_name: "")
    controller = controller_class.new(user: user)

    controller.set_current_palette

    assert_includes controller.keystone_palette_css, "--color-custom-text: #3b2f1e"
  end

  test "writes the configured custom colours for a visitor who is not signed in" do
    controller = controller_class.new(user: nil)

    controller.set_current_palette

    assert_includes controller.keystone_palette_css, "--color-custom-background: #{KeystoneUi::Colors.configuration.default_background}"
  end

  test "writes the custom text colour on a request served from the session cache" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "#e11d48", surface: "#f5e6c8", text: "#3b2f1e", template_name: "")
    session = {}
    controller_class.new(user: user, session: session).set_current_palette
    cached = controller_class.new(user: user, session: session)

    cached.set_current_palette

    assert_includes cached.keystone_palette_css, "--color-custom-text: #3b2f1e"
  end

  test "rereads a preference cached before text colours were kept" do
    pref = KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "#e11d48", surface: "#f5e6c8", text: "#3b2f1e", template_name: "")
    session = { keystone_ui_colors_palette: { accent: pref.accent, surface: pref.surface, mode: nil, updated_at: pref.updated_at.to_i } }
    controller = controller_class.new(user: user, session: session)

    controller.set_current_palette

    assert_includes controller.keystone_palette_css, "--color-custom-text: #3b2f1e"
  end

  test "the host's palette replaces a signed-in user's saved colours" do
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "emerald", surface: "stone")
    controller = controller_class.new(user: user)
    controller.set_current_palette

    controller.apply_host_palette

    assert_includes controller.keystone_palette_css, "--color-accent-500: #3b82f6"
  end

  test "a user's own colours give way to the app's when the app does not let accounts choose" do
    KeystoneUi::Colors.configuration.account_colors = false
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "emerald", surface: "stone")
    controller = controller_class.new(user: user)

    controller.set_current_palette

    assert_includes controller.keystone_palette_css, "--color-accent-500: #3b82f6"
  ensure
    KeystoneUi::Colors.reset_configuration!
  end
end
