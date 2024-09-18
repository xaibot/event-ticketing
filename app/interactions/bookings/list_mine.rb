# frozen_string_literal: true

class Bookings::ListMine < ActiveInteraction::Base
  integer :limit, :offset, :user_id

  validates :limit, :offset, :user_id, presence: true
  validates :limit, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :offset, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, numericality: { greater_than: 0 }

  def execute
    bookings = Booking.where(user_id:)
    bookings = bookings.limit(limit).offset(offset).order(id: :asc)

    Rails.cache.fetch(bookings.cache_key_with_version, expires_in: 24.hours) { bookings.load }
  end
end
