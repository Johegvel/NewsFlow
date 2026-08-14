class ApplicationController < ActionController::API
  def current_user
    return @current_user if defined?(@current_user)

    token = request.headers["Authorization"].to_s.split(" ").last
    payload = JsonWebToken.decode(token)

    @current_user = User.find(payload[:sub])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    @current_user = nil
  end

  def authenticate_user!
    return if current_user.present?

    render json: {
      error: "Token inválido o ausente"
    }, status: :unauthorized
  end
end