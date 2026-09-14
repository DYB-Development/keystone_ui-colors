# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include KeystoneUi::Colors::CurrentPalette

  before_action :set_current_palette
end
