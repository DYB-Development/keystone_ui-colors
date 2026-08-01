# frozen_string_literal: true

module KeystoneUi
  module Colors
    module Templates
      PRESETS = {
        ocean: {
          accent: :blue,
          surface: :slate,
          label: "Ocean",
          description: "Cool blues with slate undertones"
        },
        forest: {
          accent: :emerald,
          surface: :stone,
          label: "Forest",
          description: "Natural greens with warm stone"
        },
        twilight: {
          accent: :violet,
          surface: :zinc,
          label: "Twilight",
          description: "Deep violet with clean zinc"
        },
        coral: {
          accent: :rose,
          surface: :neutral,
          label: "Coral",
          description: "Warm rose with neutral balance"
        },
        arctic: {
          accent: :cyan,
          surface: :gray,
          label: "Arctic",
          description: "Bright cyan with crisp gray"
        }
      }.freeze

      def self.all
        PRESETS.merge(default: default_template)
      end

      def self.[](name)
        return default_template if name.to_sym == :default

        PRESETS.fetch(name.to_sym)
      end

      def self.names
        [ :default ] + PRESETS.keys
      end

      def self.default_template
        {
          accent: KeystoneUi::Colors.configuration.default_accent,
          surface: KeystoneUi::Colors.configuration.default_surface,
          label: "Default",
          description: "Default theme"
        }
      end
    end
  end
end
