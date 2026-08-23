require "test_helper"

module Api
  module V1
    class PreferencesControllerTest < ActionDispatch::IntegrationTest
      setup do
        password = "NewsFlow123!"
        @user = User.create!(
          name: "Preferencias",
          email: "preferences-#{SecureRandom.hex(6)}@example.com",
          password: password,
          password_confirmation: password
        )
        @headers = { "Authorization" => "Bearer #{JsonWebToken.encode(@user.id)}" }
      end

      test "preferencias se crean con defaults y persisten cambios" do
        get api_v1_me_preferences_url, headers: @headers
        assert_response :ok
        assert_equal true, response.parsed_body["reading_history_enabled"]

        patch api_v1_me_preferences_url,
              params: {
                preferences: {
                  reading_history_enabled: false,
                  morning_digest_enabled: false
                }
              },
              headers: @headers,
              as: :json

        assert_response :ok
        assert_equal false, response.parsed_body["reading_history_enabled"]
        assert_equal false, response.parsed_body["morning_digest_enabled"]
        assert_equal true, response.parsed_body["curation_alerts_enabled"]
      end

      test "historial de lectura se puede borrar" do
        community = Community.create!(
          name: "Tecnología",
          slug: "tech-#{SecureRandom.hex(5)}",
          topic: "Tecnología"
        )
        post_record = Post.create!(
          title: "Lectura",
          content: "Contenido",
          user: @user,
          community: community
        )
        PostRead.create!(user: @user, post: post_record)

        assert_difference("PostRead.count", -1) do
          delete api_v1_me_read_history_url, headers: @headers
        end
        assert_response :no_content
      end
    end
  end
end
