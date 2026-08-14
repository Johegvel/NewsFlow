module Api
  module V1
    class InterestsController < ApplicationController
      def index
        interests = Interest.order(:name)

        render json: interests.as_json(
          only: [:id, :name, :slug]
        )
      end
    end
  end
end