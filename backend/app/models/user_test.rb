require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "usuario válido con nombre y correo" do
    user = User.new(
      name: "Johan",
      email: "johan@example.com"
    )

    assert user.valid?
  end

  test "correo electrónico obligatorio" do
    user = User.new(name: "Johan")

    assert_not user.valid?
  end
end