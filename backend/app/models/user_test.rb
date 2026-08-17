require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "usuario válido con nombre y correo" do
    user = User.new(
      name: "Johan",
      email: "johan@example.com",
      password: "NewsFlow123!",
      password_confirmation: "NewsFlow123!"
    )

    assert user.valid?
  end

  test "correo electrónico obligatorio" do
    user = User.new(name: "Johan")

    assert_not user.valid?
  end
end