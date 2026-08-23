# frozen_string_literal: true

demo_password = ENV.fetch('FLEWS_DEMO_PASSWORD', 'FlewsDemo2026!')
demo_users = [
  { name: 'Juan Pérez', email: 'demo1@flews.app' },
  { name: 'María Torres', email: 'demo2@flews.app' }
].map do |attributes|
  user = User.find_or_initialize_by(email: attributes[:email])
  user.name = attributes[:name]
  user.password = demo_password
  user.password_confirmation = demo_password
  user.save!
  user
end

bot = User.find_by!(email: 'bot@flews.app')
communities = Community.where(slug: %w[tecnologia ciencia salud gastronomia deportes ciberseguridad negocios]).index_by(&:slug)
interests = Interest.where(slug: %w[tecnologia ciencia salud gastronomia deportes ciberseguridad negocios]).index_by(&:slug)

news_definitions = [
  {
    title: 'La inteligencia artificial transforma el diagnóstico preventivo',
    content: "Un nuevo modelo clínico combina historiales médicos y patrones de sueño para anticipar riesgos cardiovasculares con mayor precisión.\n\n• 📊 Relevancia: 9.4/10\n• Fuente: Flews Editorial\n• Enlace original: https://example.com/salud-ia",
    community: communities.fetch('salud'),
    published_at: Time.zone.parse('2026-08-22 09:00:00')
  },
  {
    title: 'Un modelo abierto reduce el consumo energético de la inteligencia artificial',
    content: "Investigadores publicaron una arquitectura eficiente que disminuye el costo de entrenamiento sin sacrificar precisión en tareas generales.\n\n• 📊 Relevancia: 8.9/10\n• Fuente: Flews Editorial\n• Enlace original: https://example.com/tecnologia-modelo",
    community: communities.fetch('tecnologia'),
    published_at: Time.zone.parse('2026-08-22 08:00:00')
  },
  {
    title: 'Un telescopio terrestre detecta una atmósfera con señales de agua',
    content: "El análisis espectroscópico de un exoplaneta cercano reveló componentes compatibles con vapor de agua y abrió una nueva etapa de observación.\n\n• 📊 Relevancia: 8.7/10\n• Fuente: Flews Editorial\n• Enlace original: https://example.com/ciencia-exoplaneta",
    community: communities.fetch('ciencia'),
    published_at: Time.zone.parse('2026-08-21 18:30:00')
  },
  {
    title: 'La fermentación de precisión avanza en la gastronomía sostenible',
    content: "Científicos de alimentos y cocineros desarrollaron perfiles de sabor complejos con un menor uso de agua y suelo.\n\n• 📊 Relevancia: 8.2/10\n• Fuente: Flews Editorial\n• Enlace original: https://example.com/gastronomia-fermentacion",
    community: communities.fetch('gastronomia'),
    published_at: Time.zone.parse('2026-08-21 16:00:00')
  },
  {
    title: 'El análisis biomecánico mejora la prevención de lesiones deportivas',
    content: "Una plataforma de captura de movimiento permite ajustar cargas de entrenamiento y detectar patrones asociados a lesiones recurrentes.\n\n• 📊 Relevancia: 8.5/10\n• Fuente: Flews Editorial\n• Enlace original: https://example.com/deportes-biomecanica",
    community: communities.fetch('deportes'),
    published_at: Time.zone.parse('2026-08-21 13:00:00')
  },
  {
    title: 'Nueva herramienta abierta detecta dependencias vulnerables en minutos',
    content: "La comunidad de seguridad presentó un escáner reproducible para identificar paquetes comprometidos antes del despliegue.\n\n• 📊 Relevancia: 9.1/10\n• Fuente: Flews Editorial\n• Enlace original: https://example.com/ciberseguridad-dependencias",
    community: communities.fetch('ciberseguridad'),
    published_at: Time.zone.parse('2026-08-21 10:00:00')
  },
  {
    title: 'Las startups regionales priorizan crecimiento sostenible sobre expansión acelerada',
    content: "Nuevas empresas latinoamericanas están ajustando sus estrategias hacia ingresos recurrentes, eficiencia operativa y mercados especializados.\n\n• 📊 Relevancia: 8.4/10\n• Fuente: Flews Editorial\n• Enlace original: https://example.com/negocios-startups",
    community: communities.fetch('negocios'),
    published_at: Time.zone.parse('2026-08-20 17:00:00')
  }
]

news_posts = news_definitions.map do |attributes|
  post = Post.find_or_initialize_by(title: attributes[:title])
  post.assign_attributes(attributes.merge(user: bot, post_type: :opinion, status: :published))
  post.save!
  post
end

critique_definitions = [
  {
    title: 'La precisión clínica también necesita explicabilidad',
    content: 'El avance es prometedor, pero su adopción debe incluir auditorías independientes, explicaciones comprensibles y validación en poblaciones diversas.',
    user: demo_users.first,
    community: communities.fetch('salud'),
    published_at: Time.zone.parse('2026-08-22 10:30:00')
  },
  {
    title: 'Eficiencia energética no significa acceso democrático',
    content: 'Reducir el costo de entrenamiento ayuda, aunque el acceso a datos de calidad y capacidad de cómputo todavía concentra el desarrollo en pocas organizaciones.',
    user: demo_users.last,
    community: communities.fetch('tecnologia'),
    published_at: Time.zone.parse('2026-08-22 11:00:00')
  },
  {
    title: 'La ciberseguridad abierta necesita mantenimiento sostenible',
    content: 'Las herramientas abiertas fortalecen el ecosistema, pero requieren financiamiento, responsables claros y tiempos de respuesta medibles ante vulnerabilidades.',
    user: demo_users.first,
    community: communities.fetch('ciberseguridad'),
    published_at: Time.zone.parse('2026-08-22 11:30:00')
  }
]

critique_posts = critique_definitions.map do |attributes|
  post = Post.find_or_initialize_by(title: attributes[:title])
  post.assign_attributes(attributes.merge(post_type: :critique, status: :published))
  post.save!
  post
end

Comment.find_or_create_by!(
  post: news_posts.first,
  user: demo_users.last,
  content: 'La validación externa será clave antes de utilizar este modelo en decisiones clínicas.'
)
Comment.find_or_create_by!(
  post: critique_posts.first,
  user: demo_users.last,
  content: 'También sería útil publicar métricas separadas por edad y región.'
)

Reaction.find_or_create_by!(post: news_posts.first, user: demo_users.first) { |reaction| reaction.kind = :helpful }
Reaction.find_or_create_by!(post: news_posts.first, user: demo_users.last) { |reaction| reaction.kind = :interesting }
Reaction.find_or_create_by!(post: critique_posts.first, user: demo_users.last) { |reaction| reaction.kind = :like }

SavedPost.find_or_create_by!(post: news_posts.first, user: demo_users.first)
SavedPost.find_or_create_by!(post: news_posts.second, user: demo_users.first)
SavedPost.find_or_create_by!(post: news_posts.third, user: demo_users.last)

interest_slugs_by_user = {
  demo_users.first => %w[tecnologia ciencia salud ciberseguridad],
  demo_users.last => %w[tecnologia gastronomia deportes negocios]
}

interest_slugs_by_user.each do |user, slugs|
  slugs.each do |slug|
    UserInterest.find_or_create_by!(user: user, interest: interests.fetch(slug))
  end
end

puts "Datos demo cargados: #{news_posts.size} noticias, #{critique_posts.size} críticas y 2 usuarios de prueba."
