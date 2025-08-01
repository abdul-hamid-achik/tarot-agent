# frozen_string_literal: true

# Setup code coverage - must be first
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_group 'Models', 'lib/tarot_agent/models'
  add_group 'Services', 'lib/tarot_agent/services'
  add_group 'CLI', 'lib/tarot_agent/cli'
end

require 'bundler/setup'
require 'rspec'
require 'pry'
require 'dotenv'

# Load test environment variables
Dotenv.load('.env.test')

# Set environment to test
ENV['APP_ENV'] = 'test'

# Load the application
require_relative '../lib/tarot_agent'
require_relative '../config/database'

# Database cleaner configuration
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Use expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order
  config.order = :random
  
  # Seed global randomization
  Kernel.srand config.seed

  # Database setup and teardown
  config.before(:suite) do
    # Ensure test database exists
    TarotAgent::Database.connect!
    
    # Run migrations if needed
    ActiveRecord::Migration.maintain_test_schema!
    
    # Load seed data for tests
    load File.expand_path('../db/seeds.rb', __dir__)
  end

  config.before(:each) do
    # Start a transaction
    ActiveRecord::Base.connection.begin_transaction(joinable: false)
  end

  config.after(:each) do
    # Rollback the transaction
    ActiveRecord::Base.connection.rollback_transaction
  end

  # Allow focusing on specific tests
  config.filter_run_when_matching :focus
  
  # Mocking configuration
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

# Helper method to capture stdout
def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_stdout
end

# Helper to create test data
module TestHelpers
  def create_test_card(attributes = {})
    default_attributes = {
      name: "Test Card #{rand(1000)}",
      arcana: 'major',
      number: rand(0..21),
      keywords: 'test, keywords, example',
      upright_meaning: 'Test upright meaning',
      reversed_meaning: 'Test reversed meaning',
      element: 'Fire',
      description: 'Test card description'
    }
    
    TarotAgent::Models::TarotCard.create!(default_attributes.merge(attributes))
  end
  
  def create_test_reading(attributes = {})
    default_attributes = {
      question: 'What does the future hold?',
      spread_type: 'single',
      querent_name: 'Test User',
      performed_at: Time.current
    }
    
    TarotAgent::Models::Reading.create!(default_attributes.merge(attributes))
  end
  
  # Mock Claude API response
  def mock_claude_response(text = 'Test interpretation')
    {
      'content' => [
        {
          'type' => 'text',
          'text' => text
        }
      ]
    }
  end
end

# Include helpers in all specs
RSpec.configure do |config|
  config.include TestHelpers
end