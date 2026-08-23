require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "publicación válida" do
    user = User.create!(
      name: "Johan",
      email: "johan@example.com",
      password: "NewsFlow123!",
      password_confirmation: "NewsFlow123!"
    )

    community = Community.create!(
      name: "Tecnología",
      slug: "tecnologia-#{SecureRandom.hex(4)}",
      topic: "Tecnología"
    )

    post = Post.new(
      user: user,
      community: community,
      title: "Nueva publicación",
      content: "Contenido de prueba"
    )

    assert post.valid?
  end
end
