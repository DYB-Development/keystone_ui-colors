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
        @preference = theme_preference

        if preference_params[:template_name].present?
          template = Templates[preference_params[:template_name]]
          @preference.assign_attributes(
            accent: template[:accent].to_s,
            surface: template[:surface].to_s,
            template_name: preference_params[:template_name]
          )
        else
          @preference.assign_attributes(preference_params)
        end

        if @preference.save
          redirect_to keystone_ui_colors.settings_path, notice: "Color settings updated."
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

      def current_owner
        send(KeystoneUi::Colors.configuration.current_owner_method)
      end

      def theme_preference
        ThemePreference.find_or_initialize_by(owner: current_owner)
      end

      def preference_params
        params.require(:theme_preference).permit(:accent, :surface, :template_name, :mode)
      end
    end
  end
end
