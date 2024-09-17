class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveInteraction::InvalidInteractionError do |ex|
    render json: { error: ex.message }, status: :unprocessable_entity
  end

  def params_with_current_user
    params.merge(user_id: current_user.id)
  end
end
