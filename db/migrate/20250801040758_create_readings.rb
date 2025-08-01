class CreateReadings < ActiveRecord::Migration[7.2]
  def change
    create_table :readings do |t|
      # Reading details
      t.string :question, null: false
      t.string :spread_type # 'single', 'three_card', 'celtic_cross', etc.
      t.text :cards_drawn # JSON array of card IDs and positions
      
      # AI interpretation
      t.text :claude_interpretation
      t.text :claude_advice
      
      # Metadata
      t.string :querent_name # Person asking the question
      t.datetime :performed_at
      
      t.timestamps
    end
    
    add_index :readings, :performed_at
    add_index :readings, :spread_type
  end
end
