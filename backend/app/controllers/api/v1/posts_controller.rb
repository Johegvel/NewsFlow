module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user!, only: [:create]
      
      def index
        posts = Post.includes(:user, :community)
                    .order(created_at: :desc)

        if params[:community_id].present?
          posts = posts.where(community_id: params[:community_id])
        end

        render json: posts.map { |post| post_json(post) }
      end

      def show
        post = Post.includes(:user, :community, :comments, :reactions)
                   .find(params[:id])

        render json: post_json(post).merge(
          comments_count: post.comments.count,
          reactions_count: post.reactions.count
        )
      end

      def create
        post = current_user.posts.new(post_params)

        if params[:community_id].present?
          post.community_id = params[:community_id]
        end

        if post.save
          render json: post_json(post), status: :created
        else
          render json: {
            errors: post.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      private

      def post_params
        params.require(:post).permit(
          :community_id,
          :title,
          :content,
          :post_type,
          :status,
          :published_at
        )
      end

      def post_json(post)
        {
          id: post.id,
          title: post.title,
          content: post.content,
          post_type: post.post_type,
          status: post.status,
          published_at: post.published_at,
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
      end
    end
  end
end