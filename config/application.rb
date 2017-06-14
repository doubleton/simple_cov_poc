require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

if ENV['TEST_COV']
  require 'simplecov'
  require 'securerandom'

  SimpleCov.at_exit do
    SimpleCov.result
    Redis.current.sadd(ENV.fetch('TESTS_KEY') { 'tests' }, ENV.fetch('TEST_COV'))
  end

  if ENV['TARGET_BRANCH']
    SimpleCov.add_filter GitDiffFilter.new(ENV['TARGET_BRANCH'])
  end

  SimpleCov.start 'rails' do
    command_name "Manual Tests #{SecureRandom.uuid}"
    coverage_dir 'app/views/testings'
    add_filter '/vendor/'
  end
end

module SimpleCovPoc
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
