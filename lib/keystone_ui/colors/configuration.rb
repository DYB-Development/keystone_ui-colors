# frozen_string_literal: true

module KeystoneUi
  module Colors
    class Configuration
      attr_accessor :current_owner_method, :authentication_method, :default_template, :default_accent, :default_surface, :default_mode, :default_background, :default_text, :layout

      def initialize
        @current_owner_method = :current_user
        @authentication_method = :authenticate_user!
        @default_template = :ocean
        @default_accent = "blue"
        @default_surface = "zinc"
        @default_mode = "light"
        @default_background = "#ffffff"
        @default_text = "#18181b"
        @layout = "application"
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    def self.reset_configuration!
      @configuration = Configuration.new
    end
  end
end
