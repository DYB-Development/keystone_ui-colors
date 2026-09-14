# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
require "rails/test_help"
require "minitest/mock"

ActiveRecord::Schema.define do
  create_table :keystone_ui_colors_theme_preferences, force: true do |t|
    t.string :accent, null: false
    t.string :surface, null: false
    t.string :template_name
    t.string :mode
    t.references :owner, polymorphic: true, null: false
    t.timestamps
  end

  create_table :users, force: true do |t|
    t.string :name
  end
end

Rails.application.config.action_dispatch.show_exceptions = :none

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)
end
