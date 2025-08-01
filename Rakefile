# frozen_string_literal: true

require 'standalone_migrations'

# Load standalone migrations tasks
StandaloneMigrations::Tasks.load_tasks

# Add custom tasks here if needed
desc 'Setup the database (create, migrate, seed)'
task setup: ['db:create', 'db:migrate', 'db:seed'] do
  puts 'Database setup complete!'
end

desc 'Reset the database (drop, create, migrate, seed)'
task reset: ['db:drop', 'db:create', 'db:migrate', 'db:seed'] do
  puts 'Database reset complete!'
end