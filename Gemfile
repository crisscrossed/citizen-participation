source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.13'
gem 'chosen-rails'

group :production do
  gem 'pg'
  gem 'thin'
  gem 'thinking-sphinx', '3.0.3'
  gem 'flying-sphinx',
       :git => 'git://github.com/flying-sphinx/flying-sphinx.git',
       :ref => 'f87bbbd519'
  gem 'mysql2'
end

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do
  gem "better_errors"
  gem 'letter_opener'
  gem 'quiet_assets'
end
group :development, :test do
  gem 'rspec-rails'
  gem 'spring'
  gem "factory_girl_rails"
  gem 'sqlite3'
  gem "email_spec"
  gem "selenium-webdriver"
  gem "binding_of_caller"
  gem "pry-rails"
end

group :test do
  gem 'rb-fsevent', '~> 0.9.1'
  gem "faker", "~> 1.0.1"
  gem "launchy"
  gem 'capybara'
  gem "database_cleaner", "~> 0.7.2"
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-ui-sass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem "recaptcha", :require => "recaptcha/rails"
gem 'jquery-rails'
gem 'devise'
gem 'haml-rails'
gem 'cancan'
gem 'nested_form'
gem "ancestry"
gem 'mini_magick'
gem 'truncate_html'
gem 'rinku', '~> 1.7', :require => 'rails_rinku'
gem 'paper_trail'
gem 'diffy'
gem 'carrierwave'
gem "fog", "~> 1.3.1"
gem 'kaminari'
gem 'stringex'
gem 'cartodb-rb-client', github: 'Vizzuality/cartodb-rb-client'
gem 'leaflet-rails'
gem 'rollbar'
gem 'rails_12factor'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
