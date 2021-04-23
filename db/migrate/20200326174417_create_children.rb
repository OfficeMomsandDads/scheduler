class CreateChildren < ActiveRecord::Migration[6.0]
  def change
    create_table :children do |t|
      t.references :need, null: false
      t.integer :age, null: false
      t.integer :sex, null: false
      t.text :notes

      t.timestamps
    end
  end
end
