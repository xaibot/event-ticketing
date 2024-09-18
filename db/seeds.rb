# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def seed_users
  users = FactoryBot.create_list(:user, 49)
  users << FactoryBot.create(:user, email: 'user@example.com', password: 'book-me-now')
end

def seed_events(users:)
  print "Seeding events: "

  # Generate 200_000 records
  20.times.each do
    events = FactoryBot.build_list(:event, 1_000, user: users.sample)
                       .map { _1.attributes.except(*%w[id created_at updated_at]) }

    Event.upsert_all(events, unique_by: :id)
    print '.'
  end

  puts
end

def seed_booking(users:)
  print "Seeding bookings: "

  last_event_id = Event.order(id: :asc).last.id

  users.each do |user|
    event_ids = 1_000.times.map { rand(1..last_event_id) }

    bookings =
      Event.where(id: event_ids).map do |event|
        FactoryBot.build(:booking, event:, user:, booked_tickets: 1)
                  .attributes.except(*%w[id created_at updated_at])
      end

    Booking.upsert_all(bookings, unique_by: :id)

    print '.'
  end

  puts
end

users = seed_users

seed_events(users:)
seed_booking(users:)
