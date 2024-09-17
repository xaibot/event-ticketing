# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :event, inverse_of: :bookings
  belongs_to :user, inverse_of: :bookings

  validates :event_id, :user_id, :booked_tickets, presence: true
  validates :event_id, numericality: { greater_than: 0 }
  validates :user_id, numericality: { greater_than: 0 }
end
