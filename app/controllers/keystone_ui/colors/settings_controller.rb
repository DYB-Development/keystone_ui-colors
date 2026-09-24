# frozen_string_literal: true

module KeystoneUi
  module Colors
    class SettingsController < ApplicationController
      def show
      end

      def destroy
        ThemePreference.find_by(owner: current_owner)&.destroy
        redirect_to keystone_ui_colors.settings_path, notice: "Color settings reset to default."
      end

      def update
        result = PickColours.new(person: current_owner, account: nil, values: preference_params).call

        return render :show, status: :unprocessable_entity unless result.ok?

        ForgetTheThemeChoice.new(controller: self).call
        redirect_to keystone_ui_colors.settings_path, notice: "Color settings updated."
      end

      private

      helper_method :current_owner

      def current_owner
        send(KeystoneUi::Colors.configuration.current_owner_method)
      end

      def preference_params
        params.permit(:accent, :surface, :text, :template_name, :mode).to_h.symbolize_keys
      end
    end
  end
end
