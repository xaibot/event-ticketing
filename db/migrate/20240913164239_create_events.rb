class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.references :user, null: false

      t.string :name, null: false
      t.text :description, null: false
      t.string :address, null: false
      t.datetime :starts_at, null: false
      t.integer :max_tickets, null: false
      t.integer :booked_tickets, null: false, default: 0

      t.timestamps
    end
  end
end
