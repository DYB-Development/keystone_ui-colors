# frozen_string_literal: true

require "test_helper"

class HostRouteHelpersTest < ActiveSupport::TestCase
  test "controllers outside the gem are not given the host's route helpers" do
    assert_not ActionController::Base._helpers.include?(Rails.application.routes.url_helpers)
  end
end
