# Tarot Agent 🔮

A modern CLI tarot reader powered by Claude 3.5 Sonnet. This agent provides insightful tarot readings with AI-powered interpretations.

## Features

- **Multiple Spread Types**: Single card, Three-card (Past/Present/Future), and Relationship spreads
- **AI Interpretations**: Powered by Claude 3.5 Sonnet for deep, contextual readings
- **Interactive CLI**: Beautiful terminal interface with colors and prompts
- **Reading History**: Save and review past readings
- **Card Browser**: Explore tarot card meanings
- **Follow-up Questions**: Ask Claude follow-up questions about your reading

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd tarot-agent
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
```

4. Configure your environment:
```bash
cp .env.example .env
# Edit .env and add your Anthropic API key
```

## Usage

### Start a Reading
```bash
./bin/tarot-agent reading
```

This will:
1. Ask for your name
2. Ask for your question
3. Let you choose a spread type
4. Draw cards and provide AI interpretation

### View Reading History
```bash
./bin/tarot-agent history
```

Browse your past readings and revisit interpretations.

### Explore Tarot Cards
```bash
./bin/tarot-agent cards
```

Learn about tarot card meanings and symbolism.

### Other Commands
```bash
# Show help
./bin/tarot-agent help

# Show version
./bin/tarot-agent version
```

## Configuration

Set these environment variables in your `.env` file:

- `ANTHROPIC_API_KEY`: Your Anthropic API key (required)
- `APP_ENV`: Environment (development/production)
- `LOG_LEVEL`: Logging level (info/debug/error)

## Architecture

The application follows a clean, modular architecture:

- **Models** (`lib/tarot_agent/models/`): ActiveRecord models for cards and readings
- **Services** (`lib/tarot_agent/services/`): Business logic and API integration
- **CLI** (`lib/tarot_agent/cli/`): Thor-based command-line interface
- **Database**: SQLite with ActiveRecord ORM

## Dependencies

- Ruby 3.2+
- SQLite3
- Anthropic Ruby SDK (official)
- Thor (CLI framework)
- TTY gems (terminal UI)
- ActiveRecord (ORM)

## Testing

The project includes a comprehensive test suite using RSpec with:
- Unit tests for models and services
- Integration tests for complete workflows
- Mocked Claude API responses for testing
- Test coverage reporting with SimpleCov

### Running Tests

Run all tests:
```bash
./bin/test
```

Run specific test file:
```bash
bundle exec rspec spec/services/tarot_service_spec.rb
```

Run with coverage report:
```bash
bundle exec rspec
# Coverage report will be in coverage/index.html
```

Run specific test by line number:
```bash
bundle exec rspec spec/models/tarot_card_spec.rb:42
```

### Test Structure
```
spec/
├── models/          # Model unit tests
├── services/        # Service layer tests
├── cli/            # CLI interface tests
├── integration/    # Full workflow tests
└── spec_helper.rb  # Test configuration
```

### Continuous Integration
Tests run automatically on GitHub Actions for:
- Ruby 3.2 and 3.3
- Code linting with RuboCop
- Test coverage reporting

## Development

### Database Tasks
```bash
# Create new migration
bundle exec rake db:new_migration name=migration_name

# Run migrations
bundle exec rake db:migrate

# Reset database
bundle exec rake reset
```

### Code Style
```bash
bundle exec rubocop
```

## License

MIT License

## Contributing

Pull requests are welcome! Please ensure code follows Ruby style guidelines and includes tests.

## Support

For issues or questions, please open an issue on GitHub.