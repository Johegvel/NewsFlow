require "test_helper"

module Api
  module V1
    class InteractionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        password = "NewsFlow123!"
        @user = User.create!(
          name: "Lector de prueba",
          email: "reader-#{SecureRandom.hex(6)}@example.com",
          password: password,
          password_confirmation: password
        )
        author = User.create!(
          name: "Autor de prueba",
          email: "author-#{SecureRandom.hex(6)}@example.com",
          password: password,
          password_confirmation: password
        )
        community = Community.create!(
          name: "Ciencia",
          slug: "ciencia-#{SecureRandom.hex(5)}",
          topic: "Ciencia"
        )
        @post = Post.create!(
          title: "Noticia para interacciones",
          content: "Contenido verificable para probar guardados y reacciones.",
          post_type: :opinion,
          status: :published,
          user: author,
          community: community
        )
        @headers = { "Authorization" => "Bearer #{JsonWebToken.encode(@user.id)}" }
      end

      test "guardados incluyen el post completo y estado del lector" do
        saved_post = SavedPost.create!(user: @user, post: @post)

        get api_v1_user_saved_posts_url(@user), headers: @headers

        assert_response :ok
        body = response.parsed_body.first
        assert_equal saved_post.id, body["id"]
        assert_equal @post.title, body.dig("post", "title")
        assert_equal saved_post.id, body.dig("post", "viewer_saved_post_id")
      end

      test "crear guardado y reacción es idempotente y ambos se pueden eliminar" do
        assert_difference("SavedPost.count", 1) do
          post api_v1_post_saved_posts_url(@post), headers: @headers, as: :json
        end
        saved_id = response.parsed_body["id"]
        assert_equal saved_id, response.parsed_body.dig("post", "viewer_saved_post_id")

        assert_no_difference("SavedPost.count") do
          post api_v1_post_saved_posts_url(@post), headers: @headers, as: :json
        end
        assert_response :ok

        assert_difference("Reaction.count", 1) do
          post api_v1_post_reactions_url(@post),
               params: { reaction: { kind: "like" } }, headers: @headers, as: :json
        end
        reaction_id = response.parsed_body["id"]

        get api_v1_posts_url, headers: @headers
        post_json = response.parsed_body.find { |item| item["id"] == @post.id }
        assert_equal reaction_id, post_json["viewer_reaction_id"]
        assert_equal 1, post_json["reactions_count"]

        assert_difference("Reaction.count", -1) do
          delete api_v1_reaction_url(reaction_id), headers: @headers
        end
        assert_difference("SavedPost.count", -1) do
          delete api_v1_saved_post_url(saved_id), headers: @headers
        end
      end

      test "una noticia se cuenta como leída una sola vez" do
        assert_difference("PostRead.count", 1) do
          post api_v1_post_post_reads_url(@post), headers: @headers
        end
        assert_equal 1, response.parsed_body["reads_count"]

        assert_no_difference("PostRead.count") do
          post api_v1_post_post_reads_url(@post), headers: @headers
        end
        assert_equal 1, response.parsed_body["reads_count"]

        get api_v1_me_profile_url, headers: @headers
        assert_equal 1, response.parsed_body["reads_count"]
      end
    end
  end
end
