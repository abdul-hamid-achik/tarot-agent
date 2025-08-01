class CreateTarotCards < ActiveRecord::Migration[7.2]
  def change
    create_table :tarot_cards do |t|
      # Card identification
      t.string :name, null: false
      t.string :arcana, null: false # 'major' or 'minor'
      t.string :suit # For minor arcana: cups, wands, swords, pentacles
      t.integer :number # Card number (0-21 for major, 1-14 for minor)
      
      # Card meanings
      t.text :upright_meaning
      t.text :reversed_meaning
      t.text :keywords
      
      # Card attributes
      t.string :element # Fire, Water, Air, Earth, Spirit
      t.string :astrological_sign
      t.text :description
      
      t.timestamps
    end
    
    add_index :tarot_cards, :name, unique: true
    add_index :tarot_cards, :arcana
    add_index :tarot_cards, [:suit, :number]
  end
end
