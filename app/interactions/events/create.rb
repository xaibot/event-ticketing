# frozen_string_literal: true

class Events::Create < ActiveInteraction::Base
  string :name, :description, :address
  date_time :starts_at
  integer :max_tickets

  def execute
    event = Event.new(inputs)

    event.save ? event : errors.merge!(event.errors)
  end
end
