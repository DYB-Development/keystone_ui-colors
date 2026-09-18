# frozen_string_literal: true

module KeystoneUi
  module Colors
    class SettingsController < ApplicationController
      def show
        @preference = theme_preference
      end

      def destroy
        ThemePreference.find_by(owner: current_owner)&.destroy
        redirect_to keystone_ui_colors.settings_path, notice: "Color settings reset to default."
      end

      def update
        result = PickColours.new(owner: current_owner, values: preference_params).call

        unless result.ok?
          @preference = theme_preference
          @preference.assign_attributes(preference_params.slice(:accent, :surface, :mode))
          return render :show, status: :unprocessable_entity
        end

        cookies.delete(KeystoneUi::ThemeChoice::COOKIE)
        redirect_to keystone_ui_colors.settings_path, notice: "Color settings updated."
      end

      private

      helper_method :current_owner

      def current_owner
        send(KeystoneUi::Colors.configuration.current_owner_method)
      end

      def theme_preference
        ThemePreference.find_or_initialize_by(owner: current_owner)
      end

      def preference_params
        params.permit(:accent, :surface, :template_name, :mode).to_h.symbolize_keys
      end
    end
  end
end
