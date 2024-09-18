# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    association :event
    association :user

    after :build do |booking|
      booking.booked_tickets ||= rand(1..booking.event.max_tickets)
    end
  end
end
