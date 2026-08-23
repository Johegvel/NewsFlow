module Api
  module V1
    class ProfileController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: {
          reads_count: current_user.post_reads.count,
          critiques_count: current_user.posts.where(post_type: :critique).count,
          saved_count: current_user.saved_posts.count
        }
      end

      def clear_read_history
        current_user.post_reads.delete_all
        head :no_content
      end
    end
  end
end
