source "https://rubygems.org"

gemspec

gem "rake"
gem "rails"
gem "minitest", "~> 5.0"  # pin to 5.x; minitest 6 removed minitest/mock
gem "sqlite3"
gem "capybara"
gem "rubocop-rails-omakase", require: false

# The contract this gem is checked against, in development only
gem "hub_kernel", github: "DYB-Development/hub_kernel", group: :development

# json 3.0.2 broke ActiveSupport JSON decoding
gem "json", "~> 2.21", ">= 2.21.2"
