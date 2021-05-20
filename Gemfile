source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Commented out Ruby Version for ease of local compatibility
# ruby '2.7.0'

# -------------------------
# ALPHABETICAL ORDER PLEASE
# -------------------------
gem 'bootsnap', '>= 1.4.2', require: false
gem 'pry'
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0.3'
# gem "sentry-raven"
gem 'sqlite3', '~> 1.4'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker'
  gem 'rspec-rails', '~> 4.0.0'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
