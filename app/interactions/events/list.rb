# frozen_string_literal: true

class Events::List < ActiveInteraction::Base
  integer :limit, :offset
  integer :user_id, default: nil

  validates :limit, :offset, presence: true
  validates :limit, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :offset, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, numericality: { greater_than: 0 }, allow_nil: true

  def execute
    events = user_id.present? ? Event.where(user_id:) : Event.where(nil)
    events = events.limit(limit).offset(offset).order(id: :asc)

    Rails.cache.fetch(events.cache_key_with_version, expires_in: 24.hours) { events.load }
  end
end
