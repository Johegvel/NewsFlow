module Api
  module V1
    class SavedPostsController < ApplicationController
      before_action :authenticate_user!

      def index
        saved_posts = current_user.saved_posts.includes(:post)
        render json: saved_posts
      end

      def create
        post = Post.find(params[:post_id])
        saved_post = current_user.saved_posts.find_or_initialize_by(post: post)

        if saved_post.save
          render json: saved_post, status: :created
        else
          render json: { errors: saved_post.errors.full_messages },
                status: :unprocessable_entity
        end
      end

      def destroy
        saved_post = SavedPost.find(params[:id])
        saved_post.destroy!

        head :no_content
      end

      private

      def saved_post_params
        params.require(:saved_post).permit(:post_id)
      end

      def saved_post_json(saved_post)
        post = saved_post.post

        {
          id: saved_post.id,
          created_at: saved_post.created_at,
          post: {
            id: post.id,
            title: post.title,
            content: post.content,
            post_type: post.post_type,
            status: post.status,
            user: {
              id: post.user.id,
              name: post.user.name
            },
            community: {
              id: post.community.id,
              name: post.community.name,
              slug: post.community.slug
            }
          }
        }
      end
    end
  end
end