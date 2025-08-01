# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Ruby CLI application that provides interactive tarot card readings using Claude 3.5 Sonnet AI. The application follows a clean, service-oriented architecture with Thor for CLI, ActiveRecord for data persistence, and TTY gems for terminal UI.

## Common Development Commands

### Setup and Installation
```bash
bundle install
bundle exec rake db:create db:migrate db:seed  # Setup database with tarot cards
```

### Running the Application
```bash
./bin/tarot-agent reading    # Start interactive tarot reading
./bin/tarot-agent history    # View past readings
./bin/tarot-agent cards      # Browse tarot deck
```

### Testing
```bash
./bin/test                   # Run full test suite with coverage
bundle exec rspec            # Run all RSpec tests
bundle exec rspec spec/models/tarot_card_spec.rb  # Run specific test file
bundle exec rspec spec/models/tarot_card_spec.rb:25  # Run specific test line
```

### Code Quality
```bash
bundle exec rubocop          # Run linting
bundle exec rubocop -a       # Auto-fix linting issues
```

### Database Management
```bash
bundle exec rake db:migrate  # Run pending migrations
bundle exec rake reset       # Reset database (drop, create, migrate, seed)
bundle exec rake setup       # Setup database from scratch
```

## Architecture Overview

### Service Layer Pattern
The application uses a service-oriented design where business logic is encapsulated in service objects:

- **ClaudeService** (`lib/tarot_agent/services/claude_service.rb`) - Handles all Claude AI API interactions. Centralizes prompt engineering and response parsing.
- **TarotService** (`lib/tarot_agent/services/tarot_service.rb`) - Manages tarot reading logic, card selection, and spread interpretations.

### CLI Structure
Commands are implemented in `lib/tarot_agent/cli/app.rb` using Thor. Each command delegates to appropriate services, keeping the CLI layer thin.

### Models and Database
- **TarotCard** - Represents individual cards with suits, meanings, elements, and arcana types
- **Reading** - Stores user readings with timestamps, spread types, and Claude's interpretations
- Uses SQLite in development/test, designed to work with PostgreSQL in production

### Testing Strategy
- Full test coverage with RSpec, FactoryBot for test data, and SimpleCov for coverage reporting
- Tests are organized by type: models, services, and CLI
- Uses VCR for recording API interactions in tests

### Key Design Decisions
1. **Zeitwerk Autoloading**: Modern Ruby code loading eliminates manual requires
2. **Environment-based Configuration**: Separate configs for development/test/production
3. **Service Objects**: Business logic isolated from CLI and models
4. **Interactive Terminal UI**: Rich user experience with TTY gems for prompts, spinners, and formatted output

## Important Implementation Notes

- The Anthropic API key must be set in the environment as `ANTHROPIC_API_KEY`
- Database seeds include the complete 78-card tarot deck with detailed meanings
- The application supports multiple spread types: three-card, celtic-cross, and single-card
- All user interactions are persisted for history viewing
- Error handling includes graceful API failures with user-friendly messages