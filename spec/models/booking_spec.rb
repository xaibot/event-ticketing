# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :event_id }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :booked_tickets }
  end
end
