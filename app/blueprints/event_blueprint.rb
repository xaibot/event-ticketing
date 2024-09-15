# frozen_string_literal: true

class EventBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :address, :max_tickets
  field(:starts_at) { _1.starts_at.iso8601 }
end
