# frozen_string_literal: true

module KeystoneUi
  module Colors
    class PickColours
      def initialize(values:, person: nil, account: nil, owner: nil)
        @owner = person || owner
        @account = account
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

      def mode_only
        defaults = preference.new_record? ? { accent: KeystoneUi::Colors.configuration.default_accent, surface: KeystoneUi::Colors.configuration.default_surface } : {}
        defaults.merge(mode: @values[:mode]).compact
      end

      def custom_colours
        colours = { accent: @values[:accent], surface: @values[:surface], text: @values[:text], mode: @values[:mode] }.compact
        colours[:template_name] = nil if @values.key?(:template_name)
        colours
      end

      def chosen_colours
        return mode_only unless ColourChoice.new(person: @owner, account: @account).person_chooses?

        return custom_colours if @values[:template_name].blank?

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
