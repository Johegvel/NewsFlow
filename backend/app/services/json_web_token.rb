class JsonWebToken
  ALGORITHM = "HS256"

  def self.encode(user_id, exp: 2.hours.from_now)
    payload = {
      sub: user_id,
      exp: exp.to_i,
      type: "access"
    }

    JWT.encode(
      payload,
      Rails.application.secret_key_base,
      ALGORITHM
    )
  end

  def self.encode_refresh(user_id, exp: 90.days.from_now)
    payload = {
      sub: user_id,
      exp: exp.to_i,
      type: "refresh"
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