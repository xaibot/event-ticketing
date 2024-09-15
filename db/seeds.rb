# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


def seed_events
  print "Seeding events: "

  # Generate 200_000 records
  200.times.each do
    events = FactoryBot.build_list(:event, 1_000).map { _1.attributes.except(*%w[id created_at updated_at]) }
    Event.upsert_all(events, unique_by: :id)
    print '.'
  end

  puts
end

seed_events
