require "test_helper"

class CommunityTest < ActiveSupport::TestCase
  test "comunidad válida" do
    community = Community.new(
      name: "Tecnología",
      slug: "tecnologia",
      topic: "Tecnología"
    )

    assert community.valid?
  end
end
