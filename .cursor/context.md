# Tarot Agent Project Context

## Quick Reference

### Project Structure
```
tarot-agent/
├── bin/tarot-agent          # Main executable
├── lib/
│   ├── tarot_agent.rb       # Main entry point
│   └── tarot_agent/
│       ├── cli/app.rb       # Thor CLI commands
│       ├── models/          # ActiveRecord models
│       └── services/        # Business logic services
├── db/                      # Database files and migrations
├── spec/                    # RSpec tests
└── config/                  # Configuration files
```

### Key Services
- **ClaudeService**: Manages Claude AI API calls for tarot interpretations
- **TarotService**: Handles card selection, spreads, and reading logic

### Database Schema
- **tarot_cards**: 78 cards with names, suits, meanings, elements
- **readings**: User sessions with questions, spreads, and interpretations

### Available CLI Commands
```bash
./bin/tarot-agent reading    # Interactive tarot reading
./bin/tarot-agent history    # View past readings
./bin/tarot-agent cards      # Browse tarot deck
```

### Environment Setup
```bash
# Required environment variable
export ANTHROPIC_API_KEY="your-api-key"

# Database setup
bundle exec rake db:create db:migrate db:seed
```

### Testing Commands
```bash
./bin/test                   # Run full test suite with coverage
bundle exec rspec spec/path  # Run specific tests
```

### Common Development Tasks

#### Adding a New CLI Command
1. Add method to `lib/tarot_agent/cli/app.rb`
2. Use `desc` and `method_option` for documentation
3. Delegate logic to appropriate service

#### Adding a New Service
1. Create file in `lib/tarot_agent/services/`
2. Follow existing service patterns
3. Add corresponding spec file

#### Modifying Database Schema
1. Generate migration: `bundle exec rake db:new_migration name=AddFieldToModel`
2. Edit migration file in `db/migrate/`
3. Run: `bundle exec rake db:migrate`

### Code Patterns to Follow

#### Service Object Pattern
```ruby
class MyService
  def self.call(...)
    new(...).call
  end

  def initialize(params)
    @params = params
  end

  def call
    # Business logic here
  end

  private
  # Helper methods
end
```

#### Error Handling
```ruby
def safe_operation
  yield
rescue Anthropic::Error => e
  puts "API Error: #{e.message}"
  # Graceful fallback
end
```

#### TTY UI Pattern
```ruby
spinner = TTY::Spinner.new("[:spinner] Loading...", format: :pulse_2)
spinner.auto_spin
# Long operation
spinner.success("Done!")
```