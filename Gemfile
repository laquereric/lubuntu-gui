# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in lubuntu-gui.gemspec
gemspec

gem "rake", "~> 13.0"
gem "inifile", "~> 3.0"

group :development, :test do
  gem "rspec", "~> 3.12"
  gem "cucumber", "~> 9.0"
  gem "yard", "~> 0.9"
  gem "rubocop", "~> 1.50"
  gem "rubocop-rspec", "~> 2.20"
  gem "simplecov", "~> 0.22"
  gem "pry", "~> 0.14"
  gem "pry-byebug", "~> 3.10"
end

group :test do
  gem "webmock", "~> 3.18"
  gem "vcr", "~> 6.1"
end

