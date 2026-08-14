class JsonWebToken
  ALGORITHM = "HS256"

  def self.encode(user_id)
    payload = {
      sub: user_id,
      exp: 24.hours.from_now.to_i
    }

    JWT.encode(
      payload,
      Rails.application.secret_key_base,
      ALGORITHM
    )
  end

  def self.decode(token)
    decoded = JWT.decode(
      token,
      Rails.application.secret_key_base,
      true,
      algorithm: ALGORITHM
    )

    decoded.first.with_indifferent_access
  end
end