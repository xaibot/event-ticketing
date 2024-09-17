# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :user, inverse_of: :events

  validates :user_id, :name, :description, :address, :starts_at, :max_tickets, presence: true
  validates :name, :address, length: { in: 1..256 }
  validates :user_id, numericality: { greater_than: 0 }
  validates :max_tickets, numericality: { greater_than: 0 }
end
