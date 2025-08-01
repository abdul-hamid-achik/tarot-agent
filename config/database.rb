# frozen_string_literal: true

require 'active_record'
require 'yaml'
require 'erb'

module TarotAgent
  module Database
    class << self
      # Initialize database connection
      def connect!
        config = database_config[environment]
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.logger = Logger.new($stdout) if development?
        
        # Ensure connection is established
        ActiveRecord::Base.connection
      rescue ActiveRecord::NoDatabaseError
        puts "Database doesn't exist. Run: rake db:create db:migrate"
        exit 1
      end

      # Get current environment
      def environment
        ENV['APP_ENV'] || 'development'
      end

      # Check if in development mode
      def development?
        environment == 'development'
      end

      # Load database configuration
      def database_config
        config_file = File.join(root_path, 'db', 'config.yml')
        YAML.load(ERB.new(File.read(config_file)).result, aliases: true)
      end

      # Get project root path
      def root_path
        File.expand_path('..', __dir__)
      end
    end
  end
end