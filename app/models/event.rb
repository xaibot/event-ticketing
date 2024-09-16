# frozen_string_literal: true

class Event < ApplicationRecord
  validates :name, :description, :address, :starts_at, :max_tickets, presence: true
  validates :name, :address, length: { in: 1..256 }
  validates :max_tickets, numericality: { greater_than: 0 }
end
