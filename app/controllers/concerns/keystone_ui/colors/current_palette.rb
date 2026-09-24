# frozen_string_literal: true

require "active_support/concern"

module KeystoneUi
  module Colors
    module CurrentPalette
      extend ActiveSupport::Concern

      included do
        helper_method :keystone_palette_css, :keystone_theme_mode if respond_to?(:helper_method)
      end

      def set_current_palette
        owner = send(KeystoneUi::Colors.configuration.current_owner_method)

        return apply_host_palette unless owner

        cached = session[:keystone_ui_colors_palette]

        if cached && !stale_cache?(owner, cached)
          @keystone_theme_mode = cached[:mode] || KeystoneUi::Colors.configuration.default_mode
          build_palette_css(
            cached[:accent],
            cached[:surface],
            KeystoneUi::Colors::CustomColours.new(template_name: cached[:template_name], surface: cached[:surface], text: cached[:text])
          )
          return
        end

        preference = KeystoneUi::Colors::ThemePreference.find_by(owner: owner)
        @keystone_theme_mode = preference&.mode || KeystoneUi::Colors.configuration.default_mode
        accent = preference&.accent || KeystoneUi::Colors.configuration.default_accent
        surface = preference&.surface || KeystoneUi::Colors.configuration.default_surface

        custom = KeystoneUi::Colors::CustomColours.new(template_name: preference&.template_name, surface: surface, text: preference&.text)
        build_palette_css(accent, surface, custom)

        if preference
          session[:keystone_ui_colors_palette] = {
            accent: preference.accent,
            surface: preference.surface,
            mode: preference.mode,
            template_name: preference.template_name,
            text: preference.text,
            updated_at: preference.updated_at.to_i
          }
        end
      end

      def apply_host_palette
        @keystone_theme_mode = KeystoneUi::Colors.configuration.default_mode
        build_palette_css(
          KeystoneUi::Colors.configuration.default_accent,
          KeystoneUi::Colors.configuration.default_surface,
          KeystoneUi::Colors::CustomColours.new(template_name: nil, surface: nil, text: nil)
        )
      end

      def keystone_palette_css
        @keystone_palette_css
      end

      def keystone_theme_mode
        @keystone_theme_mode
      end

      private

      def build_palette_css(accent, surface, custom = nil)
        accent_shades = resolve_shades(accent, :accent)
        surface_shades = resolve_shades(surface, :surface)

        lines = []
        accent_shades.each { |shade, hex| lines << "  --color-accent-#{shade}: #{hex};" }
        surface_shades.each { |shade, hex| lines << "  --color-surface-#{shade}: #{hex};" }
        lines << "  --color-custom-background: #{custom.background};" if custom
        lines << "  --color-custom-text: #{custom.text};" if custom

        @keystone_palette_css = ":root {\n#{lines.join("\n")}\n}"
      end

      def resolve_shades(value, type)
        if value&.start_with?("#")
          KeystoneUi::Colors::Palettes.generate_shades(value)
        else
          (type == :accent) ? KeystoneUi::Colors::Palettes.accent(value) : KeystoneUi::Colors::Palettes.surface(value)
        end
      end

      def stale_cache?(owner, cached)
        return true unless cached.key?(:text)

        updated_at = KeystoneUi::Colors::ThemePreference
          .where(owner: owner)
          .pick(:updated_at)

        return true unless updated_at

        updated_at.to_i != cached[:updated_at]
      end
    end
  end
end
