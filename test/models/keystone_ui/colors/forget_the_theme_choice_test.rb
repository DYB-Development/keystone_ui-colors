# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::ForgetTheThemeChoiceTest < ActiveSupport::TestCase
  class PretendController
    def initialize(request) = @request = request

    attr_reader :request
  end

  test "it forgets the browser's saved theme choice" do
    request = ActionDispatch::TestRequest.create
    request.cookie_jar[KeystoneUi::ThemeChoice::COOKIE] = "dark"

    KeystoneUi::Colors::ForgetTheThemeChoice.new(controller: PretendController.new(request)).call

    assert_nil request.cookie_jar[KeystoneUi::ThemeChoice::COOKIE]
  end
end
