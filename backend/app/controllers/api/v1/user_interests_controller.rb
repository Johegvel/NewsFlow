module Api
  module V1
    class UserInterestsController < ApplicationController
      def show
        user = User.find(params[:user_id])

        render json: user.interests
                         .order(:name)
                         .as_json(only: [:id, :name, :slug])
      end

      def update
        user = User.find(params[:user_id])
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