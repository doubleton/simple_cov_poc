require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

if ENV['TEST_COV']
  require 'simplecov'
  SimpleCov.start 'rails' do
    command_name "Manual Tests PID #{$$}"
    coverage_dir 'app/views/coverage'
  end
end

module SimpleCovPoc
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
