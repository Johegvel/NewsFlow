require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  DEMO_NEWS_TITLES = [
    "La inteligencia artificial transforma el diagnóstico preventivo",
    "Un modelo abierto reduce el consumo energético de la inteligencia artificial",
    "Un telescopio terrestre detecta una atmósfera con señales de agua",
    "La fermentación de precisión avanza en la gastronomía sostenible",
    "El análisis biomecánico mejora la prevención de lesiones deportivas",
    "Nueva herramienta abierta detecta dependencias vulnerables en minutos",
    "Las startups regionales priorizan crecimiento sostenible sobre expansión acelerada"
  ].freeze

  DEMO_CRITIQUE_TITLES = [
    "La precisión clínica también necesita explicabilidad",
    "Eficiencia energética no significa acceso democrático",
    "La ciberseguridad abierta necesita mantenimiento sostenible"
  ].freeze

  test "las semillas demo son completas e idempotentes" do
    load Rails.root.join("db/seeds.rb")

    counts_after_first_load = record_counts

    load Rails.root.join("db/seeds.rb")

    assert_equal counts_after_first_load, record_counts
    assert_equal 7, Community.where(slug: %w[tecnologia ciencia salud gastronomia deportes ciberseguridad negocios]).count
    assert_equal 7, Interest.where(slug: %w[tecnologia ciencia salud gastronomia deportes ciberseguridad negocios]).count
    assert_equal 7, Post.where(title: DEMO_NEWS_TITLES).count
    assert_equal 3, Post.where(title: DEMO_CRITIQUE_TITLES).count

    bot = User.find_by!(email: "bot@flews.app")
    assert Post.where(title: DEMO_NEWS_TITLES).all? { |post| post.user == bot }
    assert Post.where(title: DEMO_CRITIQUE_TITLES).none? { |post| post.user == bot }

    demo_user = User.find_by!(email: "demo1@flews.app")
    assert demo_user.authenticate("FlewsDemo2026!")
    assert demo_user.saved_posts.exists?
    assert demo_user.interests.exists?
  end

  private

  def record_counts
    [
      User.count,
      Community.count,
      Interest.count,
      Post.count,
      Comment.count,
      Reaction.count,
      SavedPost.count,
      UserInterest.count
    ]
  end
end
