class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
    	t.string :filename
    	t.integer :year
    	t.integer :month
    	t.integer :generation
    	t.string :tier
    	t.integer :min_rank

      t.timestamps null: false
    end
  end
end
