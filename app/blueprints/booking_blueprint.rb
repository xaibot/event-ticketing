# frozen_string_literal: true

class BookingBlueprint < Blueprinter::Base
  identifier :id

  fields :event_id, :user_id, :booked_tickets
end
