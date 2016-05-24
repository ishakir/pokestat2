class CreateUsages < ActiveRecord::Migration
  def change
    create_table :usages do |t|
      t.references :source
    	t.string :pokemon
    	t.float :usage_pct
    	t.integer :raw
    	t.float :raw_pct
    	t.integer :real
    	t.float :real_pct

      t.timestamps null: false
    end
  end
end
