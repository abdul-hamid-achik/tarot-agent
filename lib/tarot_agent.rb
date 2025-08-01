# frozen_string_literal: true

require 'zeitwerk'
require 'active_record'
require 'dotenv'

# Load environment variables
Dotenv.load

# Main module for Tarot Agent
module TarotAgent
  # Set up autoloading with Zeitwerk
  def self.loader
    @loader ||= begin
      loader = Zeitwerk::Loader.for_gem
      loader.push_dir(File.expand_path('tarot_agent', __dir__))
      loader.setup
      loader
    end
  end
  
  # Initialize the application
  def self.initialize!
    # Load the gem
    loader
    
    # Connect to database
    require_relative '../config/database'
    Database.connect!
  end
end

# Initialize on require
TarotAgent.initialize!