# frozen_string_literal: true

class Bookings::Create < ActiveInteraction::Base
  # TO DO: consider replacing TIMEOUT by an env var (loading it via Rails.configuration).
  TIMEOUT = 5

  integer :event_id, :user_id, :tickets_to_book

  def execute
    with_lock do
      # We perform these validations during the `execute` phase so that the event is loaded after the lock is acquired.
      return errors.add(:base, "Could not find event with id #{event_id}") unless event.present?
      return errors.add(:base, "Not enough tickets available") unless enough_tickets_available?

      Event.transaction do
        event.update!(booked_tickets: event.booked_tickets + tickets_to_book)

        booking = Booking.new(event_id:, user_id:, booked_tickets: tickets_to_book)
        booking.save ? booking : errors.merge!(booking.errors)
      end
    end
  end

  private

  def available_tickets
    event.max_tickets - event.booked_tickets
  end

  def enough_tickets_available?
    tickets_to_book <= available_tickets
  end

  def event
    @event ||= Event.find_by_id(event_id)
  end

  def with_lock(&)
    outcome = Event.with_advisory_lock_result("lock_for_event_#{event_id}", timeout_seconds: TIMEOUT, &)

    outcome.lock_was_acquired? ? outcome.result : errors.add(:base, "Could not book the tickets")
  end
end
