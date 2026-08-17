module Api
  module V1
    module Auth
      class RegistrationsController < ApplicationController
        def create
          user = User.new(user_params)

          if user.save
            render json: {
              token: JsonWebToken.encode(user.id),
              user: user_json(user)
            }, status: :created
          else
            render json: {
              errors: user.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.require(:user).permit(
            :name,
            :email,
            :password,
            :password_confirmation
          )
        end

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