# frozen_string_literal: true

require 'thor'
require 'tty-prompt'
require 'tty-spinner'
require 'tty-box'
require 'pastel'
require_relative '../services/tarot_service'
require_relative '../../config/database'

module TarotAgent
  module CLI
    # Main CLI application using Thor
    class App < Thor
      def initialize(*args)
        super
        @prompt = TTY::Prompt.new
        @pastel = Pastel.new
        @tarot_service = Services::TarotService.new
        
        # Connect to database
        TarotAgent::Database.connect!
      end
      
      desc 'reading', 'Start a new tarot reading session'
      def reading
        clear_screen
        display_welcome
        
        # Get querent's name
        name = @prompt.ask('What is your name?', default: 'Seeker')
        
        # Get the question
        question = @prompt.ask('What would you like to know about?') do |q|
          q.required true
          q.validate { |input| input.length > 5 }
          q.messages[:valid?] = 'Please ask a more detailed question (at least 5 characters)'
        end
        
        # Choose spread type
        spread = @prompt.select('Choose your spread:') do |menu|
          menu.choice 'Single Card - Quick insight', :single
          menu.choice 'Three Cards - Past, Present, Future', :three_card
          menu.choice 'Relationship - Five card spread', :relationship
        end
        
        # Perform the reading with a spinner
        reading = nil
        spinner = TTY::Spinner.new(
          "#{@pastel.cyan('🔮 Consulting the cards...')} :spinner",
          format: :dots
        )
        
        spinner.auto_spin
        
        case spread
        when :single
          reading = @tarot_service.single_card_reading(question, name)
        when :three_card
          reading = @tarot_service.three_card_reading(question, name)
        when :relationship
          reading = @tarot_service.relationship_reading(question, name)
        end
        
        spinner.success(@pastel.green('✨ Reading complete!'))
        
        # Display the reading
        display_reading(reading)
        
        # Offer follow-up options
        handle_followup(reading)
      end
      
      desc 'history', 'View your recent readings'
      def history
        clear_screen
        puts @pastel.cyan.bold('📚 Recent Readings')
        puts '-' * 50
        
        readings = @tarot_service.recent_readings(10)
        
        if readings.empty?
          puts @pastel.yellow('No readings found. Start with "tarot-agent reading"')
          return
        end
        
        readings.each do |reading|
          display_reading_summary(reading)
        end
        
        # Allow viewing full reading
        if @prompt.yes?('Would you like to view a full reading?')
          id = @prompt.ask('Enter reading ID:', convert: :int)
          reading = @tarot_service.get_reading(id)
          
          if reading
            display_reading(reading)
            handle_followup(reading)
          else
            puts @pastel.red('Reading not found')
          end
        end
      end
      
      desc 'cards', 'Browse tarot card meanings'
      def cards
        clear_screen
        puts @pastel.cyan.bold('🎴 Tarot Card Browser')
        puts '-' * 50
        
        choice = @prompt.select('What would you like to explore?') do |menu|
          menu.choice 'Major Arcana', :major
          menu.choice 'Minor Arcana', :minor
          menu.choice 'Search by keyword', :search
          menu.choice 'Random card', :random
        end
        
        case choice
        when :major
          display_cards(TarotAgent::Models::TarotCard.major_arcana)
        when :minor
          suit = @prompt.select('Choose a suit:') do |menu|
            menu.choice 'Cups - Emotions & Relationships', 'cups'
            menu.choice 'Wands - Creativity & Action', 'wands'
            menu.choice 'Swords - Thoughts & Communication', 'swords'
            menu.choice 'Pentacles - Material & Career', 'pentacles'
          end
          display_cards(TarotAgent::Models::TarotCard.by_suit(suit))
        when :search
          keyword = @prompt.ask('Enter keyword to search:')
          cards = TarotAgent::Models::TarotCard.where('keywords LIKE ?', "%#{keyword}%")
          display_cards(cards)
        when :random
          card = TarotAgent::Models::TarotCard.draw_random
          display_card_detail(card)
        end
      end
      
      desc 'version', 'Display version information'
      def version
        puts @pastel.cyan('Tarot Agent v1.0.0')
        puts @pastel.white('A modern CLI tarot reader powered by Claude 3.5')
      end
      
      private
      
      # Clear the terminal screen
      def clear_screen
        system('clear') || system('cls')
      end
      
      # Display welcome banner
      def display_welcome
        box = TTY::Box.frame(
          width: 60,
          height: 7,
          align: :center,
          padding: 1,
          border: :thick,
          style: {
            fg: :cyan,
            border: { fg: :magenta }
          }
        ) do
          "✨ TAROT AGENT ✨\n\nYour AI-powered spiritual guide\nPowered by Claude 3.5"
        end
        
        puts box
        puts
      end
      
      # Display a full reading
      def display_reading(reading)
        puts
        puts @pastel.magenta.bold("📖 Reading ##{reading.id}")
        puts @pastel.white("Question: #{reading.question}")
        puts @pastel.white("Spread: #{reading.spread_description}")
        puts '-' * 60
        
        # Display cards
        puts @pastel.cyan.bold('Cards Drawn:')
        reading.drawn_cards.each do |card_data|
          card = TarotAgent::Models::TarotCard.find(card_data[:card_id])
          reversed = card_data[:reversed] ? ' (Reversed)' : ''
          position = card_data[:position] || 'General'
          
          puts @pastel.yellow("  #{position}: #{card.full_name}#{reversed}")
        end
        
        puts
        puts @pastel.cyan.bold('Interpretation:')
        puts word_wrap(reading.claude_interpretation)
        
        if reading.claude_advice
          puts
          puts @pastel.cyan.bold('Advice:')
          puts word_wrap(reading.claude_advice)
        end
        
        puts
        puts '-' * 60
      end
      
      # Display reading summary
      def display_reading_summary(reading)
        puts
        puts @pastel.yellow("ID: #{reading.id} | #{reading.performed_at&.strftime('%B %d, %Y')}")
        puts @pastel.white("Question: #{reading.question[0..60]}...")
        puts @pastel.cyan("Spread: #{reading.spread_description}")
        puts '-' * 30
      end
      
      # Display cards list
      def display_cards(cards)
        if cards.empty?
          puts @pastel.yellow('No cards found')
          return
        end
        
        cards.each do |card|
          puts
          puts @pastel.cyan.bold(card.full_name)
          puts @pastel.white("Keywords: #{card.keywords}")
          puts '-' * 30
        end
        
        if @prompt.yes?('View card details?')
          card_name = @prompt.select('Choose a card:', cards.map(&:full_name))
          card = cards.find { |c| c.full_name == card_name }
          display_card_detail(card)
        end
      end
      
      # Display detailed card information
      def display_card_detail(card)
        puts
        box = TTY::Box.frame(
          title: { top_left: card.full_name },
          width: 70,
          padding: 1,
          border: :thick,
          style: { border: { fg: :cyan } }
        ) do
          <<~CONTENT
            #{@pastel.yellow('Keywords:')} #{card.keywords}
            
            #{@pastel.cyan('Element:')} #{card.element || 'N/A'}
            #{@pastel.cyan('Astrological:')} #{card.astrological_sign || 'N/A'}
            
            #{@pastel.green('Upright Meaning:')}
            #{word_wrap(card.upright_meaning, 65)}
            
            #{@pastel.red('Reversed Meaning:')}
            #{word_wrap(card.reversed_meaning, 65)}
            
            #{@pastel.magenta('Description:')}
            #{word_wrap(card.description, 65)}
          CONTENT
        end
        
        puts box
      end
      
      # Handle follow-up questions
      def handle_followup(reading)
        loop do
          choice = @prompt.select('What would you like to do?') do |menu|
            menu.choice 'Ask a follow-up question', :followup
            menu.choice 'Start a new reading', :new
            menu.choice 'Exit', :exit
          end
          
          case choice
          when :followup
            question = @prompt.ask('Your follow-up question:')
            
            spinner = TTY::Spinner.new(
              "#{@pastel.cyan('🔮 Consulting Claude...')} :spinner",
              format: :dots
            )
            spinner.auto_spin
            
            response = @tarot_service.ask_followup(reading.id, question)
            spinner.success(@pastel.green('✨ Response ready!'))
            
            puts
            puts @pastel.cyan.bold('Claude\'s Response:')
            puts word_wrap(response)
            puts
          when :new
            reading
            break
          when :exit
            puts @pastel.green('Thank you for using Tarot Agent. Blessed be! ✨')
            break
          end
        end
      end
      
      # Word wrap helper
      def word_wrap(text, width = 80)
        return '' unless text
        
        text.split("\n").map do |line|
          line.scan(/.{1,#{width}}(?:\s|$)/).join("\n")
        end.join("\n")
      end
    end
  end
end