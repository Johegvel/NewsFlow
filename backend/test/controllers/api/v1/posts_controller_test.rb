require "test_helper"

module Api
  module V1
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        password = "NewsFlow123!"
        @user = User.create!(
          name: "Autor de críticas",
          email: "critique-#{SecureRandom.hex(6)}@example.com",
          password: password,
          password_confirmation: password
        )
        @community = Community.create!(
          name: "Tecnología",
          slug: "tecnologia-#{SecureRandom.hex(4)}",
          topic: "Tecnología"
        )
        @headers = {
          "Authorization" => "Bearer #{JsonWebToken.encode(@user.id)}"
        }
      end

      test "un usuario regular no puede publicar noticias" do
        assert_no_difference("Post.count") do
          post api_v1_community_posts_url(@community),
               params: post_payload("opinion"),
               headers: @headers,
               as: :json
        end

        assert_response :forbidden
      end

      test "un usuario autenticado puede publicar una crítica" do
        assert_difference("Post.count", 1) do
          post api_v1_community_posts_url(@community),
               params: post_payload("critique"),
               headers: @headers,
               as: :json
        end

        assert_response :created
        assert_equal @user.id, Post.last.user_id
        assert_predicate Post.last, :critique?
      end

      private

      def post_payload(post_type)
        {
          post: {
            title: "Análisis de prueba",
            content: "Argumentos y contexto suficientes para una crítica editorial.",
            post_type: post_type,
            status: "published"
          }
        }
      end
    end
  end
end
