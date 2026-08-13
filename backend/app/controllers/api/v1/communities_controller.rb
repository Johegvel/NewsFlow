module Api
  module V1
    class CommunitiesController < ApplicationController
      def index
        communities = Community.order(created_at: :desc)

        render json: communities.map { |community| community_json(community) }
      end

      def show
        community = Community.find(params[:id])

        render json: {
          id: community.id,
          name: community.name,
          slug: community.slug,
          description: community.description,
          topic: community.topic,
          posts: community.posts.order(created_at: :desc).map do |post|
            post_json(post)
          end
        }
      end

      private

      def community_json(community)
        {
          id: community.id,
          name: community.name,
          slug: community.slug,
          description: community.description,
          topic: community.topic,
          posts_count: community.posts.count
        }
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
          }
        }
      end
    end
  end
end