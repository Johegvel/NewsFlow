module Api
  module V1
    class SavedPostsController < ApplicationController
      before_action :authenticate_user!

      def index
        saved_posts = current_user.saved_posts
                                  .includes(post: [:user, :community])
                                  .order(created_at: :desc)
        posts = saved_posts.map(&:post).compact
        serialized_posts = serialize_posts(posts).index_by { |post| post[:id] }

        valid_saved_posts = saved_posts.select { |sp| sp.post.present? && serialized_posts.key?(sp.post_id) }
        render json: valid_saved_posts.map { |saved_post| saved_post_json(saved_post, serialized_posts) }
      end

      def create
        post = Post.find(params[:post_id])
        saved_post = current_user.saved_posts.find_or_initialize_by(post: post)
        created = saved_post.new_record?

        if saved_post.save
          serialized_posts = serialize_posts([post]).index_by { |item| item[:id] }
          render json: saved_post_json(saved_post, serialized_posts),
                 status: created ? :created : :ok
        else
          render json: { errors: saved_post.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def destroy
        saved_post = if params[:post_id].present?
                       current_user.saved_posts.find_by(post_id: params[:post_id])
                     else
                       current_user.saved_posts.find_by(id: params[:id])
                     end
        saved_post&.destroy!

        head :no_content
      end

      private

      def saved_post_json(saved_post, serialized_posts)
        {
          id: saved_post.id,
          user_id: saved_post.user_id,
          post_id: saved_post.post_id,
          created_at: saved_post.created_at,
          post: serialized_posts.fetch(saved_post.post_id)
        }
      end
    end
  end
end
