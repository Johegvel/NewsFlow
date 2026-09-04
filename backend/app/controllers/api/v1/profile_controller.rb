module Api
  module V1
    class ProfileController < ApplicationController
      before_action :authenticate_user!

      def show
        cutoff = 24.hours.ago
        render json: {
          reads_count: current_user.post_reads.where("created_at >= ?", cutoff).count,
          critiques_count: current_user.posts.where(post_type: :critique).where("created_at >= ?", cutoff).count,
          saved_count: current_user.saved_posts.count,
          comments_count: current_user.comments.where("created_at >= ?", cutoff).count
        }
      end

      def update
        if current_user.update(user_params)
          render json: {
            user: {
              id: current_user.id,
              name: current_user.name,
              email: current_user.email
            }
          }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def clear_read_history
        current_user.post_reads.delete_all
        head :no_content
      end

      private

      def user_params
        params.require(:user).permit(:name, :email)
      end
    end
  end
end