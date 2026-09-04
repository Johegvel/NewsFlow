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

      test "login y registro entregan refresh_token" do
        post api_v1_auth_login_url,
             params: { email: @user.email, password: @password },
             as: :json

        assert_response :ok
        body = response.parsed_body
        assert body["token"].present?
        assert body["refresh_token"].present?

        refresh_payload = JsonWebToken.decode(body["refresh_token"])
        assert_equal "refresh", refresh_payload[:type]
        assert_equal @user.id, refresh_payload[:sub]
      end

      test "refresh con token válido renueva la sesión" do
        refresh_token = JsonWebToken.encode_refresh(@user.id)

        post api_v1_auth_refresh_url,
             params: { refresh_token: refresh_token },
             as: :json

        assert_response :ok
        body = response.parsed_body
        assert body["token"].present?
        assert body["refresh_token"].present?
        assert_equal @user.id, body.dig("user", "id")

        new_access_payload = JsonWebToken.decode(body["token"])
        assert_equal "access", new_access_payload[:type]
        assert_equal @user.id, new_access_payload[:sub]
      end

      test "refresh rechaza token ausente, inválido o que no sea de tipo refresh" do
        post api_v1_auth_refresh_url, params: {}, as: :json
        assert_response :bad_request

        post api_v1_auth_refresh_url, params: { refresh_token: "invalido" }, as: :json
        assert_response :unauthorized

        access_token = JsonWebToken.encode(@user.id)
        post api_v1_auth_refresh_url, params: { refresh_token: access_token }, as: :json
        assert_response :unauthorized
      end

      test "endpoint protegido rechaza un refresh token usado como bearer" do
        refresh_token = JsonWebToken.encode_refresh(@user.id)

        get api_v1_auth_me_url,
            headers: { "Authorization" => "Bearer #{refresh_token}" }

        assert_response :unauthorized
      end
    end
  end
end
