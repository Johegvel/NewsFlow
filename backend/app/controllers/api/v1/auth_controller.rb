module Api
  module V1
    class AuthController < ApplicationController
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
          render json: user_json(user), status: :ok
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
          render json: user_json(user), status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/auth/me?user_id=X
      def me
        user_id = params[:user_id] || request.headers['X-User-Id']

        if user_id.present?
          user = User.find_by(id: user_id)
          if user
            render json: user_json(user), status: :ok
            return
          end
        end

        render json: { error: 'Sesión no válida o usuario no encontrado' }, status: :unauthorized
      end

      # GET /api/v1/auth/users
      def users
        users = User.order(:id)
        render json: users.map { |u| user_json(u) }, status: :ok
      end

      private

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
