module Api
  module V1
    class PostReadsController < ApplicationController
      before_action :authenticate_user!

      def create
        preference = current_user.user_preference || current_user.create_user_preference!
        unless preference.reading_history_enabled?
          render json: { tracked: false, reads_count: current_user.post_reads.count }, status: :ok
          return
        end

        post = Post.find(params[:post_id])
        post_read = current_user.post_reads.find_or_initialize_by(post: post)
        created = post_read.new_record?
        post_read.save!

        render json: {
          tracked: true,
          read_id: post_read.id,
          reads_count: current_user.post_reads.count
        }, status: created ? :created : :ok
      end
    end
  end
end
