# frozen_string_literal: true

class BookingsController < ApplicationController
  before_action :authenticate_user!

  def list_mine
    bookings = Bookings::ListMine.run!(params_with_current_user)

    render status: :ok, json: BookingBlueprint.render(bookings)
  end

  def create
    booking = Bookings::Create.run!(params_with_current_user)

    render status: :created, json: BookingBlueprint.render(booking)
  end
end
