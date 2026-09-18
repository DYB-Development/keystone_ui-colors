# frozen_string_literal: true

require "test_helper"
require "hub_kernel"
require "hub_kernel/conformance/action"
require "hub_kernel/conformance/partial"

class PickColoursConformanceTest < ActiveSupport::TestCase
  include HubKernel::Conformance::Action

  saving_object { KeystoneUi::Colors::PickColours }

  def a_person = User.create!(name: "Test")

  def an_account = nil

  def values_it_keeps = { template_name: "ocean" }

  def values_it_refuses = { accent: "neon", surface: "slate" }
end

class PickerConformanceTest < ActionView::TestCase
  include KeystoneUiHelper
  include HubKernel::Conformance::Partial

  markup { "keystone_ui/colors/settings/picker" }

  def a_person = User.create!(name: "Test")

  def an_account = nil
end
