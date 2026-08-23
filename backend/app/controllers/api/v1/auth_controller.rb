module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: [:me]

      # POST /api/v1/auth/login
      def login
        email = params[:email].to_s.strip.downcase
        password = params[:password].to_s

        if email.blank? || password.blank?
          render json: { error: 'Correo electrónico y contraseña son requeridos' }, status: :bad_request
          return
        end

        user = User.find_by('LOWER(email) = ?', email)

        if user&.authenticate(password)
          render json: auth_json(user), status: :ok
        else
          render json: { error: 'Credenciales inválidas. Verifica tu correo o contraseña.' }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/register
      def register
        name = params[:name].to_s.strip
        email = params[:email].to_s.strip.downcase
        password = params[:password].to_s

        if name.blank? || email.blank? || password.blank?
          render json: { error: 'Nombre, correo electrónico y contraseña son requeridos' }, status: :bad_request
          return
        end

        if password.length < 6
          render json: { error: 'La contraseña debe tener al menos 6 caracteres' }, status: :unprocessable_entity
          return
        end

        existing = User.find_by('LOWER(email) = ?', email)
        if existing
          render json: { error: 'Este correo electrónico ya está registrado. Por favor inicia sesión.' }, status: :conflict
          return
        end

        user = User.new(name: name, email: email, password: password, password_confirmation: password)

        if user.save
          render json: auth_json(user), status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/auth/me
      def me
        render json: user_json(current_user), status: :ok
      end

      # GET /api/v1/auth/users
      def users
        users = User.order(:id)
        render json: users.map { |u| user_json(u) }, status: :ok
      end

      private

      def auth_json(user)
        {
          token: JsonWebToken.encode(user.id),
          user: user_json(user)
        }
      end

      def user_json(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          created_at: user.created_at
        }
      end
    end
  end
end
