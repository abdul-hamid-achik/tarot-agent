# Tarot Agent 🔮

A minimal yet powerful Elixir-based CLI tool for interactive tarot readings enhanced with Claude AI. Chat with the agent naturally to receive mystical guidance through the ancient wisdom of tarot cards with modern AI insights.

## Features

- **🤖 AI-Enhanced Readings**: Powered by Claude 3 Haiku for deeper, contextual interpretations
- **💬 Interactive CLI Interface**: Natural language chat interface for intuitive interaction
- **🃏 Complete 78-Card Deck**: All Major and Minor Arcana cards with detailed meanings
- **📊 Multiple Spread Layouts**: 
  - Single Card
  - Past-Present-Future
  - Celtic Cross
  - Relationship Spread
  - Career Path
  - Mind-Body-Spirit
  - Horseshoe
  - Decision Making
- **🧠 Intelligent Interpretations**: Contextual readings based on card positions and orientations
- **🗣️ Natural Language Understanding**: Ask questions naturally like "What does The Fool mean?" or "I need career guidance"
- **🌅 Daily Card Draws**: Get your daily guidance with a single card pull
- **❓ Follow-up Questions**: Ask Claude about your readings for deeper insights
- **🔐 Secure Configuration**: API keys stored safely in your user directory

## Installation

### Prerequisites
- Elixir 1.18 or higher
- Erlang/OTP 27
- Anthropic API key (for AI features)

### Build from Source

```bash
# Clone the repository
git clone https://github.com/abdul-hamid-achik/tarot-agent.git
cd tarot_agent

# Fetch dependencies
mix deps.get

# Build the executable
mix escript.build

# Run the agent
./tarot_agent
```

### API Key Setup

The agent will prompt you for your Anthropic API key on first use. You can also configure it in advance:

**Option 1: Environment Variable**
```bash
export TAROT_AGENT_ANTHROPIC_API_KEY=sk-your-api-key-here
```

**Option 2: .env File**
```bash
cp .env.example .env
# Edit .env and add your API key
```

Get your API key at: https://console.anthropic.com/settings/keys

## Usage

### Starting the Agent
```bash
./tarot_agent
```

### Available Commands

- `help` - Show available commands and options
- `daily` - Draw your daily guidance card  
- `reading` - Get a full tarot reading with your chosen spread
- `spreads` - View all available tarot spreads
- `cards` - Explore the tarot deck
- `ask` - Ask a follow-up question about your last reading
- `config` - Show configuration status
- `test` - Test AI connection
- `clear` - Clear saved API key
- `exit` - Leave the Tarot Agent

### Natural Language Queries

The agent understands various natural language inputs:

- "Draw a single card"
- "Past present future reading"
- "Celtic cross spread"
- "Relationship reading"
- "Career guidance"
- "Help me make a decision"
- "What does The Fool mean?"
- "Tell me my fortune"
- "I need guidance about love"

### Example Session

```
🔮 Welcome to the Tarot Agent 🔮
Your mystical guide to tarot wisdom

──────────────────────────────────────────────────

✨ What would you like to do? (type 'help' for options)
> daily

🌅 Daily Card Draw
════════════════════════════════════════

Your daily card is: The Star

The Star represents hope and spiritual guidance

💭 Message: Hope, faith, purpose, renewal, spirituality

🔑 Keywords: hope, faith, purpose, renewal
🌟 Element: Air

✨ Daily Guidance:
The Star brings positive energy today. Embrace its message and let it guide your actions.

This Major Arcana card indicates an important day for spiritual growth and life lessons.

═══════════════════════════════════════
✨ Claude's Enhanced Interpretation
═══════════════════════════════════════

The Star appearing in your daily draw is truly auspicious! This card represents 
a beacon of hope cutting through any darkness you may have been experiencing...
[AI provides deeper, contextual interpretation]
```

### AI Integration

The agent uses Claude 3 Haiku by default for cost-effectiveness, but you can configure other models:

```bash
export TAROT_AGENT_AI_MODEL=claude-3-sonnet-20240229  # More capable
export TAROT_AGENT_AI_MODEL=claude-3-opus-20240229   # Most advanced
```

**Cost Considerations:**
- Claude 3 Haiku: ~$0.25 per 1M tokens (cheapest)
- Claude 3 Sonnet: ~$3 per 1M tokens (balanced)  
- Claude 3 Opus: ~$15 per 1M tokens (most capable)

A typical reading uses 200-500 tokens, costing less than $0.001 with Haiku.

### Follow-up Questions

After any reading, use the `ask` command to dive deeper:

```
> ask
❓ What would you like to ask about your reading?
> How can I best harness the energy of The Star today?

✨ Claude's Response
═══════════════════════════════════════
To harness The Star's energy today, focus on...
```

## Project Structure

```
tarot_agent/
├── lib/
│   └── tarot_agent/
│       ├── cards.ex        # Complete tarot deck data
│       ├── spreads.ex      # Spread layouts and positions
│       ├── reading_engine.ex # Reading interpretation logic
│       └── cli.ex          # CLI interface and chat logic
├── mix.exs                 # Project configuration
└── README.md
```

## Architecture

The agent is built with a modular architecture:

1. **Cards Module**: Contains all 78 tarot cards with their meanings, keywords, and elemental associations
2. **Spreads Module**: Defines various spread layouts with position meanings
3. **Reading Engine**: Performs readings, interprets cards in context, and generates synthesis
4. **CLI Module**: Handles user interaction, natural language processing, and display

## Development

### Running Tests
```bash
mix test
```

### Interactive Development
```bash
iex -S mix
```

### Compiling
```bash
mix compile
```

## Inspired By

This project was inspired by the [tarot-mcp](https://github.com/abdul-hamid-achik/tarot-mcp) tool, reimagined as an Elixir-based agentic CLI application.

## License

MIT

## Contributing

Feel free to open issues or submit pull requests to improve the agent's capabilities or add new features!

## Future Enhancements

- [ ] Add more sophisticated natural language processing
- [ ] Implement reading history and favorites
- [ ] Add custom spread creation
- [ ] Include card imagery (ASCII art)
- [ ] Support for multiple languages
- [ ] Integration with AI services for enhanced interpretations