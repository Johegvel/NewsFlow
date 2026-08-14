module Api
  module V1
    module Auth
      class SessionsController < ApplicationController
        def create
          email = params[:email].to_s.strip.downcase
          user = User.find_by(email: email)

          if user&.authenticate(params[:password])
            render json: {
              token: JsonWebToken.encode(user.id),
              user: user_json(user)
            }
          else
            render json: {
              error: "Correo o contraseña incorrectos"
            }, status: :unauthorized
          end
        end

        def me
          authenticate_user!
          return unless current_user

          render json: user_json(current_user)
        end

        private

        def user_json(user)
          {
            id: user.id,
            name: user.name,
            email: user.email
          }
        end
      end
    end
  end
end