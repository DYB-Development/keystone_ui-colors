# frozen_string_literal: true

require "active_support/concern"

module KeystoneUi
  module Colors
    module CurrentPalette
      extend ActiveSupport::Concern

      included do
        helper_method :keystone_palette_css if respond_to?(:helper_method)
      end

      def set_current_palette
        owner = send(KeystoneUi::Colors.configuration.current_owner_method)

        unless owner
          build_palette_css(
            KeystoneUi::Colors.configuration.default_accent,
            KeystoneUi::Colors.configuration.default_surface
          )
          return
        end

        cached = session[:keystone_ui_colors_palette]

        if cached && !stale_cache?(owner, cached)
          build_palette_css(cached[:accent], cached[:surface])
          return
        end

        preference = KeystoneUi::Colors::ThemePreference.find_by(owner: owner)
        @keystone_theme_mode = preference&.mode
        accent = preference&.accent || KeystoneUi::Colors.configuration.default_accent
        surface = preference&.surface || KeystoneUi::Colors.configuration.default_surface

        build_palette_css(accent, surface)

        if preference
          session[:keystone_ui_colors_palette] = {
            accent: preference.accent,
            surface: preference.surface,
            updated_at: preference.updated_at.to_i
          }
        end
      end

      def keystone_palette_css
        @keystone_palette_css
      end

      def keystone_theme_mode
        @keystone_theme_mode
      end

      private

      def build_palette_css(accent, surface)
        accent_shades = resolve_shades(accent, :accent)
        surface_shades = resolve_shades(surface, :surface)

        lines = []
        accent_shades.each { |shade, hex| lines << "  --color-accent-#{shade}: #{hex};" }
        surface_shades.each { |shade, hex| lines << "  --color-surface-#{shade}: #{hex};" }

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
        updated_at = KeystoneUi::Colors::ThemePreference
          .where(owner: owner)
          .pick(:updated_at)

        return true unless updated_at

        updated_at.to_i != cached[:updated_at]
      end
    end
  end
end
