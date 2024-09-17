FactoryBot.define do
  factory :event do
    association :user

    name { "'#{Faker::Game.title}' #{%w[conference gathering].sample}" }
    description { Faker::Lorem.sentence }
    address { Faker::Address.full_address }
    starts_at { Faker::Time.forward(days: 90) }
    max_tickets { Faker::Number.within(range: 100..1000) }
  end
end
