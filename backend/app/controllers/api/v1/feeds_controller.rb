module Api
  module V1
    class FeedsController < ApplicationController
      before_action :authenticate_user!

      def show
        user = current_user
        topics = user.interests.pluck(:name).map(&:downcase)

        posts = Post.includes(:user, :community)
                    .where(status: :published)
                    .order(created_at: :desc)

        posts = posts.sort_by do |post|
          matches_interest = topics.include?(post.community.topic.to_s.downcase)
          priority = matches_interest ? 0 : 1

          [priority, -post.created_at.to_i]
        end

        render json: posts.map { |post| post_json(post) }
      end

      private

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
            slug: post.community.slug,
            topic: post.community.topic
          }
        }
      end
    end
  end
end