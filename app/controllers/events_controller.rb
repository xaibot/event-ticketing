# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!

  def authored
    events = Events::List.run!(params_with_current_user)

    render status: :ok, json: EventBlueprint.render(events)
  end

  def create
    event = Events::Create.run!(params_with_current_user)
    render status: :created, json: EventBlueprint.render(event)

  rescue ActiveInteraction::InvalidInteractionError => ex
    render json: { error: ex.message }, status: :unprocessable_entity
  end

  def index
    events = Events::List.run!(params)

    render status: :ok, json: EventBlueprint.render(events)
  end

  ## Should this be in BookingsController instead of here?
  # def booked
  #   events = Events::ListBookedByUser.run!(params_with_current_user)
  #
  #   render status: :ok, json: EventBlueprint.render(events)
  # end

  private

  def params_with_current_user
    params.merge(user_id: current_user.id)
  end
end
