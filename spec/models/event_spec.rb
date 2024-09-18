# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :address }
    it { is_expected.to validate_presence_of :starts_at }
    it { is_expected.to validate_presence_of :max_tickets }
    it { is_expected.to validate_presence_of :booked_tickets }

    it { is_expected.to validate_length_of(:name).is_at_least(1).is_at_most(256) }
    it { is_expected.to validate_length_of(:address).is_at_least(1).is_at_most(256) }

    it { expect(subject).to validate_numericality_of(:max_tickets).is_greater_than(0) }
    it { expect(subject).to validate_numericality_of(:booked_tickets).is_greater_than_or_equal_to(0) }
  end
end
