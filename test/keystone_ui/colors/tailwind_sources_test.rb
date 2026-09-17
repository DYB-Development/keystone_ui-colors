# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Colors::TailwindSourcesTest < ActiveSupport::TestCase
  test "the engine's views are scanned by a host's stylesheet build" do
    views = KeystoneUi::Colors::Engine.root.join("app/views/**/*.erb").to_s

    assert_includes KeystoneUi.configuration.tailwind_sources, views
  end
end
