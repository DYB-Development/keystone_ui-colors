# frozen_string_literal: true

module KeystoneUi
  module Colors
    class ThemePreference < ApplicationRecord
      self.table_name = "keystone_ui_colors_theme_preferences"

      belongs_to :owner, polymorphic: true

      SUPPORTED_ACCENTS = %w[blue emerald cyan indigo violet rose].freeze

      SUPPORTED_SURFACES = %w[zinc slate gray neutral stone].freeze

      HEX_COLOR = /\A#[0-9a-fA-F]{6}\z/

      MODES = %w[light dark system custom].freeze

      validate :accent_is_valid
      validate :surface_is_valid
      validates :template_name, inclusion: { in: Templates.names.map(&:to_s) }, allow_blank: true
      validates :mode, inclusion: { in: MODES }, allow_nil: true

      def apply_template!(name)
        template = Templates[name]
        update!(
          accent: template[:accent].to_s,
          surface: template[:surface].to_s,
          template_name: name.to_s
        )
      end

      private

      def accent_is_valid
        return if SUPPORTED_ACCENTS.include?(accent) || accent&.match?(HEX_COLOR)

        errors.add(:accent, "must be a supported color name or hex value")
      end

      def surface_is_valid
        return if SUPPORTED_SURFACES.include?(surface) || surface&.match?(HEX_COLOR)

        errors.add(:surface, "must be a supported color name or hex value")
      end
    end
  end
end
