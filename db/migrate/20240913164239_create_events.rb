class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :address, null: false
      t.datetime :starts_at, null: false
      t.integer :max_tickets, null: false

      t.timestamps
    end
  end
end
