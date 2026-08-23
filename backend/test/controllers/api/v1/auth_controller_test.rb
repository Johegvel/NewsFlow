require "test_helper"

module Api
  module V1
    class AuthControllerTest < ActionDispatch::IntegrationTest
      setup do
        @password = "NewsFlow123!"
        @user = User.create!(
          name: "Usuario JWT",
          email: "jwt-#{SecureRandom.hex(6)}@example.com",
          password: @password,
          password_confirmation: @password
        )
      end

      test "login entrega un token JWT y el usuario" do
        post api_v1_auth_login_url,
             params: { email: @user.email.upcase, password: @password },
             as: :json

        assert_response :ok

        body = response.parsed_body
        assert_equal @user.id, body.dig("user", "id")
        assert_equal @user.email, body.dig("user", "email")
        assert_equal @user.id, JsonWebToken.decode(body["token"])[:sub]
      end

      test "registro entrega un token JWT y el usuario" do
        email = "new-#{SecureRandom.hex(6)}@example.com"

        post api_v1_auth_register_url,
             params: {
               name: "Usuario Nuevo",
               email: email,
               password: @password
             },
             as: :json

        assert_response :created

        body = response.parsed_body
        assert_equal email, body.dig("user", "email")
        assert_equal body.dig("user", "id"), JsonWebToken.decode(body["token"])[:sub]
      end

      test "me requiere y valida el token Bearer" do
        get api_v1_auth_me_url
        assert_response :unauthorized

        get api_v1_auth_me_url,
            headers: { "Authorization" => "Bearer #{JsonWebToken.encode(@user.id)}" }

        assert_response :ok
        assert_equal @user.id, response.parsed_body["id"]
      end

      test "me rechaza un token inválido" do
        get api_v1_auth_me_url,
            headers: { "Authorization" => "Bearer token-invalido" }

        assert_response :unauthorized
      end
    end
  end
end
