# frozen_string_literal: true

source 'https://rubygems.org'

# Ruby version
ruby '~> 3.2'

# Core dependencies
gem 'thor', '~> 1.3'                    # Modern CLI framework
gem 'tty-prompt', '~> 0.23'             # Interactive CLI prompts
gem 'tty-spinner', '~> 0.9'             # Loading spinners
gem 'tty-box', '~> 0.7'                 # Box drawing in terminal
gem 'pastel', '~> 0.8'                  # Terminal colors

# Database
gem 'activerecord', '~> 7.1'            # ORM for database
gem 'sqlite3', '~> 1.7'                 # SQLite database
gem 'standalone_migrations', '~> 7.1'   # Migrations without Rails

# HTTP and API
gem 'anthropic', '~> 0.3'               # Official Anthropic Ruby SDK for Claude
gem 'dotenv', '~> 3.1'                  # Environment variables

# Utilities
gem 'zeitwerk', '~> 2.6'                # Modern code loading
gem 'dry-configurable', '~> 1.1'        # Configuration management
gem 'concurrent-ruby', '~> 1.2'         # Thread-safe utilities

# Development and testing
group :development, :test do
  gem 'pry', '~> 0.14'                  # Debugging
  gem 'rspec', '~> 3.13'                # Testing framework
  gem 'rubocop', '~> 1.60'              # Code linting
  gem 'rubocop-rspec', '~> 2.25'        # RSpec specific linting
  gem 'simplecov', '~> 0.22'            # Code coverage
  gem 'factory_bot', '~> 6.4'           # Test data factories
  gem 'faker', '~> 3.2'                 # Generate fake data
end