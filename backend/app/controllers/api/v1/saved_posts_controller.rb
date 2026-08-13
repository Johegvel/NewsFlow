module Api
  module V1
    class SavedPostsController < ApplicationController
      def index
        user = User.find(params[:user_id])

        saved_posts = user.saved_posts
                         .includes(post: [:user, :community])
                         .order(created_at: :desc)

        render json: saved_posts.map { |saved_post| saved_post_json(saved_post) }
      end

      def create
        post = Post.find(params[:post_id])
        user = User.find(saved_post_params[:user_id])

        saved_post = SavedPost.find_or_initialize_by(
          user: user,
          post: post
        )

        if saved_post.save
          render json: saved_post_json(saved_post),
                 status: saved_post.previously_new_record? ? :created : :ok
        else
          render json: {
            errors: saved_post.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        saved_post = SavedPost.find(params[:id])
        saved_post.destroy!

        head :no_content
      end

      private

      def saved_post_params
        params.require(:saved_post).permit(:user_id)
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