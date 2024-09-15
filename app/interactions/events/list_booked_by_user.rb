# frozen_string_literal: true

class Events::ListBookedByUser < ActiveInteraction::Base
  integer :limit, :offset, :user_id

  validates :limit, :offset, :user_id, presence: true
  validates :limit, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :offset, numericality: { greater_than_or_equal_to: 0 }

  def execute
    # TO DO: implement once booking logic is added.
    raise NotImplementedError
  end
end
