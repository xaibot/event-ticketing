# frozen_string_literal: true

class Events::List < ActiveInteraction::Base
  integer :limit, :offset

  validates :limit, :offset, presence: true
  validates :limit, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :offset, numericality: { greater_than_or_equal_to: 0 }

  def execute
    events = Event.limit(limit).offset(offset).order(id: :asc)

    Rails.cache.fetch(events.cache_key_with_version, expires_in: 24.hours) { events.load }
  end
end
