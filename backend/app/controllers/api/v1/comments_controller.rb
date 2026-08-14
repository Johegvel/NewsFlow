module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_post
      before_action :authenticate_user!, only: [:create]
      

      def index
        comments = @post.comments
                        .includes(:user)
                        .order(created_at: :asc)

        render json: comments.map { |comment| comment_json(comment) }
      end

      def create
        comment = @post.comments.new(comment_params)
        comment.user = current_user

        if comment.save
          render json: comment_json(comment), status: :created
        else
          render json: {
            errors: comment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def comment_params
        params.require(:comment).permit(:content)
      end

      def comment_json(comment)
        {
          id: comment.id,
          content: comment.content,
          created_at: comment.created_at,
          user: {
            id: comment.user.id,
            name: comment.user.name
          }
        }
      end
    end
  end
end