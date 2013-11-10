source 'http://rubygems.org'
require 'rubygems'

ruby '1.9.3'

gem 'rails', '= 3.1.3'

group :production do
  gem 'thin'
end

gem 'mongoid'#,   '= 2.5.1'
gem 'bson_ext'
gem 'googlecharts'
gem 'roo'
#gem 'yalab-ruby-ods'
# require 'ods'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem "log_buddy"#, "~> 0.0.1"
gem "random-word", "~> 1.3.0"
#gem "random-word-generator", "~> 0.0.1"
#gem 'webster'

#rack at version 1.4.1

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end
  gem 'bootstrap-sass' #for basic formating of css
  gem 'sass-rails',   '~> 3.1.5'
  gem 'font-awesome-sass-rails'

gem 'devise'
gem 'kaminari'
gem 'formtastic'
gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'


group :development, :test do
 # gem "lorem-ipsum-me"
  gem 'factory_girl_rails'                        # use factories instead of fixtures
  gem 'faker'                                     # easily create fake data for tests
  gem 'rspec-rails'                               # test framework
  gem "cucumber-rails", "~> 1.0", require: false  # integration test framework
  gem 'simplecov'                                 # test coverage report
  gem 'json_spec'                                 # easier testing of JSON
  gem 'database_cleaner'                          # manage DB between tests
  gem 'mongoid-rspec'                             # rspec matchers for mongoid
  gem 'capybara'                                  # simulates the user actions in the browser  -------- type 'guard' to start
  gem 'guard-rspec'                               # automatically run tests so you don't need to run rake test
  gem 'guard-cucumber'
  #gem 'libnotify'                                 #tells you if tests pass or fail - ubuntu
end


#group :test, :development do
#  gem 'turn' #makes output pretty
#  gem 'rspec-rails'
#  gem 'capybara' #simulates the user
#  gem 'guard-rspec' #automatically run tests so you don't need to run rake test
#  #gem 'growl_notify' #tells you if tests pass or fail - mac
#  gem 'libnotify' #tells you if tests pass or fail - ubuntu
#end


