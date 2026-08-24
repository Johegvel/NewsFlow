require "test_helper"

module NewsIngestion
  class IngestionManagerTest < ActiveSupport::TestCase
    FakeSource = Struct.new(:items) do
      def fetch_trending
        items
      end
    end

    class TestIngestionManager < IngestionManager
      def initialize(source)
        @source = source
      end

      private

      def build_adapter(*)
        @source
      end
    end

    test "crea el bot, publica noticias y evita duplicados" do
      community = Community.find_or_initialize_by(slug: "tecnologia")
      community.assign_attributes(name: "Tecnología", topic: "Tecnología")
      community.save!
      source = FakeSource.new([
        {
          title: "Una noticia relevante para probar la ingesta",
          content: "Contenido suficientemente amplio para producir un resumen editorial verificable.",
          url: "https://example.com/noticia-ingesta",
          score: 180,
          comments_count: 42,
          published_at: 1.hour.ago,
          source_name: "Fuente de prueba"
        }
      ])
      manager = TestIngestionManager.new(source)

      first_result = manager.run
      second_result = manager.run

      assert_equal 1, first_result[:total_created]
      assert_equal 0, second_result[:total_created]
      assert_equal 1, Post.where(title: "Una noticia relevante para probar la ingesta").count

      bot = User.find_by!(email: IngestionManager::SYSTEM_USER_EMAIL)
      post = Post.find_by!(title: "Una noticia relevante para probar la ingesta")
      assert bot.password_digest.present?
      assert_equal bot, post.user
      assert_equal "opinion", post.post_type
      assert_includes post.content, "https://example.com/noticia-ingesta"
    end

    test "elimina noticias expiradas mayores a 24 horas" do
      community = Community.find_or_initialize_by(slug: "tecnologia")
      community.assign_attributes(name: "Tecnología", topic: "Tecnología")
      community.save!

      bot = User.find_or_initialize_by(email: IngestionManager::SYSTEM_USER_EMAIL)
      bot.name = IngestionManager::SYSTEM_USER_NAME
      bot.password = "Secr3tP@ssw0rd!" if bot.password_digest.blank?
      bot.save!

      old_post = Post.create!(
        title: "Noticia vieja del año pasado",
        content: "Contenido viejo.",
        published_at: 48.hours.ago,
        post_type: :opinion,
        user: bot,
        community: community
      )

      manager = TestIngestionManager.new(FakeSource.new([]))
      manager.run

      assert_nil Post.find_by(id: old_post.id)
    end
  end
end
