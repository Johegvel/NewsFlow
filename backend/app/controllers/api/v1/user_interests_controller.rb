module Api
  module V1
    class UserInterestsController < ApplicationController
      before_action :authenticate_user!

      def show
        user = current_user

        render json: user.interests
                         .order(:name)
                         .as_json(only: [:id, :name, :slug])
      end

      def update
        user = current_user 
        interest_ids = params.require(:interest_ids)

        user.transaction do
          user.user_interests.delete_all

          interest_ids.each do |interest_id|
            user.user_interests.create!(interest_id: interest_id)
          end
        end

        render json: user.interests
                         .order(:name)
                         .as_json(only: [:id, :name, :slug])
      rescue ActiveRecord::RecordInvalid => error
        render json: {
          errors: [error.message]
        }, status: :unprocessable_entity
      end
    end
  end
end
