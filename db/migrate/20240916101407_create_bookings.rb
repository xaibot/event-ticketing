class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.references :event, null: false
      t.references :user, null: false
      t.integer :booked_tickets, null: false

      t.timestamps
    end
  end
end
