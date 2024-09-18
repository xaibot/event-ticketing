# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :event_id }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :booked_tickets }

    it { expect(subject).to validate_numericality_of(:booked_tickets).is_greater_than_or_equal_to(0) }
  end
end
