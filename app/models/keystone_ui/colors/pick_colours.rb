# frozen_string_literal: true

module KeystoneUi
  module Colors
    class PickColours
      def initialize(owner:, values:)
        @owner = owner
        @values = values
      end

      def call
        preference.assign_attributes(chosen_colours)

        return Refusal.new(preference.errors.full_messages.first) unless preference.save

        Kept.new
      end

      private

      def preference
        @preference ||= ThemePreference.find_or_initialize_by(owner: @owner)
      end

      def chosen_colours
        return { accent: @values[:accent], surface: @values[:surface], mode: @values[:mode] }.compact if @values[:template_name].blank?

        template = Templates[@values[:template_name]]
        {
          accent: template[:accent].to_s,
          surface: template[:surface].to_s,
          template_name: @values[:template_name],
          mode: @values[:mode]
        }.compact
      end
    end
  end
end
