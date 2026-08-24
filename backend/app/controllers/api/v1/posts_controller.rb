module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user!, only: [ :create ]

      def index
        posts = Post.includes(:user, :community)
                    .order(created_at: :desc)

        if params[:filter] == "news"
          posts = posts.where.not(post_type: :critique)
                       .where("posts.published_at >= ? OR (posts.published_at IS NULL AND posts.created_at >= ?)", 24.hours.ago, 24.hours.ago)
        elsif params[:filter] == "critiques" || params[:post_type] == "critique"
          posts = posts.where(post_type: :critique)
        elsif params[:post_type].present?
          posts = posts.where(post_type: params[:post_type])
          if params[:post_type].to_s != "critique"
            posts = posts.where("posts.published_at >= ? OR (posts.published_at IS NULL AND posts.created_at >= ?)", 24.hours.ago, 24.hours.ago)
          end
        else
          # Feed general: críticas de usuarios permanentes, noticias curadas solo de las últimas 24h
          cutoff = 24.hours.ago
          critique_enum_val = Post.post_types[:critique]
          posts = posts.where(
            "posts.post_type = :critique_enum OR posts.published_at >= :cutoff OR (posts.published_at IS NULL AND posts.created_at >= :cutoff)",
            critique_enum: critique_enum_val,
            cutoff: cutoff
          )
        end

        if params[:community_id].present?
          posts = posts.where(community_id: params[:community_id])
        end

        render json: serialize_posts(posts)
      end

      def show
        post = Post.includes(:user, :community, :comments, :reactions)
                   .find(params[:id])

        render json: serialize_posts([post]).first
      end

      def create
        unless post_params[:post_type].to_s == "critique"
          render json: {
            error: "Los usuarios solo pueden publicar críticas y análisis"
          }, status: :forbidden
          return
        end

        post = current_user.posts.new(post_params.merge(post_type: :critique))

        if params[:community_id].present?
          post.community_id = params[:community_id]
        end

        if post.save
          render json: serialize_posts([post]).first, status: :created
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

    end
  end
end
