# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    events = Events::List.run!(params)

    render status: :ok, json: EventBlueprint.render(events)
  end

  def create
    event = Events::Create.run!(params)
    render status: :created, json: EventBlueprint.render(event)

  rescue ActiveInteraction::InvalidInteractionError => ex
    render json: { error: ex.message }, status: :unprocessable_entity
  end

  def booked
    events = Events::ListBookedByUser.run!(params.merge(user_id: current_user.id))

    render status: :ok, json: EventBlueprint.render(events)
  end

  private

  def event_params
    params.fetch(:event, {})
  end
end
