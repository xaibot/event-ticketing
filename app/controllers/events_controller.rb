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
  end

  def index
    events = Events::List.run!(params)

    render status: :ok, json: EventBlueprint.render(events)
  end
end
