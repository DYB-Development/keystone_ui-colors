# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::AccountPaletteTest < ActiveSupport::TestCase
  def controller_class
    @controller_class ||= Class.new do
      include KeystoneUi::Colors::CurrentPalette

      attr_accessor :current_user, :current_account, :session

      def initialize(user:, account:)
        @current_user = user
        @current_account = account
        @session = {}
      end
    end
  end

  def setup
    KeystoneUi::Colors.configure { |config| config.current_account_method = :current_account }
  end

  def teardown
    KeystoneUi::Colors.reset_configuration!
  end

  def user
    @user ||= User.create!(name: "Member")
  end

  def account
    @account ||= Account.create!(name: "Acme")
  end

  def palette_for(user, account)
    controller = controller_class.new(user: user, account: account)
    controller.set_current_palette
    controller
  end

  test "an account's colours apply to a member who saved none" do
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone")

    assert_includes palette_for(user, account).keystone_palette_css, "--color-accent-500: #10b981"
  end

  test "a member's own colours apply when the account lets members choose" do
    KeystoneUi::Colors::ThemePreference.create!(owner: account, accent: "emerald", surface: "stone")
    KeystoneUi::Colors::ThemePreference.create!(owner: user, accent: "rose", surface: "zinc")

    assert_includes palette_for(user, account).keystone_palette_css, "--color-accent-500: #f43f5e"
  end
end
