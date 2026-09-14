# frozen_string_literal: true

require "test_helper"
require "rubygems"

class KeystoneUi::Colors::GemspecTest < ActiveSupport::TestCase
  ROOT = File.expand_path("../../..", __dir__)

  test "requires a keystone_ui that accepts a theme mode supplier" do
    requirement = Gem::Specification.load(File.join(ROOT, "keystone_ui-colors.gemspec")).dependencies.find { |d| d.name == "keystone_ui" }.requirement

    refute requirement.satisfied_by?(Gem::Version.new("0.9.1"))
  end
end
