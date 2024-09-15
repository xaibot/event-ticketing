# frozen_string_literal: true

class Events::Create < ActiveInteraction::Base
  string :name, :description, :address
  date_time :starts_at
  integer :max_tickets

  validates :name, :description, :address, :starts_at, :max_tickets, presence: true
  validates :name, :address, length: { maximum: 256 }
  validates :max_tickets, numericality: { greater_than: 0 }

  def execute
    event = Event.new(inputs)

    event.save ? event : errors.merge!(event.errors)
  end
end
