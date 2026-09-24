# frozen_string_literal: true

module KeystoneUi
  module Colors
    module Templates
      PRESETS = {
        ocean: {
          accent: :blue,
          surface: :slate,
          background: "#e0f2fe",
          text: "#0c4a6e",
          label: "Ocean",
          description: "Cool blues with slate undertones"
        },
        forest: {
          accent: :emerald,
          surface: :stone,
          background: "#ecfdf5",
          text: "#064e3b",
          label: "Forest",
          description: "Natural greens with warm stone"
        },
        twilight: {
          accent: :violet,
          surface: :zinc,
          background: "#1e1b4b",
          text: "#ede9fe",
          label: "Twilight",
          description: "Deep violet with clean zinc"
        },
        coral: {
          accent: :rose,
          surface: :neutral,
          background: "#fff1f2",
          text: "#4c0519",
          label: "Coral",
          description: "Warm rose with neutral balance"
        },
        arctic: {
          accent: :cyan,
          surface: :gray,
          background: "#ecfeff",
          text: "#164e63",
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
          background: KeystoneUi::Colors.configuration.default_background,
          text: KeystoneUi::Colors.configuration.default_text,
          label: "Default",
          description: "Default theme"
        }
      end
    end
  end
end
