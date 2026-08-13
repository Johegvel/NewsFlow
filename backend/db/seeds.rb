# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cargando datos iniciales..."

johan = User.find_or_create_by!(email: "johan@newsflow.com") do |user|
  user.name = "Johan Veloz"
end

xavier = User.find_or_create_by!(email: "xavier@newsflow.com") do |user|
  user.name = "Xavier Camacho"
end

tecnologia = Community.find_or_create_by!(slug: "tecnologia") do |community|
  community.name = "Tecnología"
  community.description = "Noticias y conversaciones sobre tecnología."
  community.topic = "Tecnología"
end

deportes = Community.find_or_create_by!(slug: "deportes") do |community|
  community.name = "Deportes"
  community.description = "Actualidad y análisis deportivo."
  community.topic = "Deportes"
end

ciencia = Community.find_or_create_by!(slug: "ciencia") do |community|
  community.name = "Ciencia"
  community.description = "Descubrimientos y avances científicos."
  community.topic = "Ciencia"
end

Post.find_or_create_by!(
  title: "La inteligencia artificial continúa transformando la tecnología"
) do |post|
  post.content = "Las nuevas herramientas de inteligencia artificial están cambiando la forma de trabajar y aprender."
  post.user = johan
  post.community = tecnologia
  post.post_type = :discussion
  post.status = :published
  post.published_at = Time.current
end

Post.find_or_create_by!(
  title: "Innovaciones tecnológicas que marcarán el futuro"
) do |post|
  post.content = "Las tendencias actuales apuntan hacia sistemas más conectados, automatizados y sostenibles."
  post.user = xavier
  post.community = tecnologia
  post.post_type = :opinion
  post.status = :published
  post.published_at = Time.current
end

Post.find_or_create_by!(
  title: "Resultados destacados de la jornada deportiva"
) do |post|
  post.content = "Resumen de los principales resultados y noticias de la jornada."
  post.user = xavier
  post.community = deportes
  post.post_type = :discussion
  post.status = :published
  post.published_at = Time.current
end

Post.find_or_create_by!(
  title: "Nuevo descubrimiento científico genera interés"
) do |post|
  post.content = "Un nuevo avance científico abre posibilidades para futuras investigaciones."
  post.user = johan
  post.community = ciencia
  post.post_type = :discussion
  post.status = :published
  post.published_at = Time.current
end

puts "Datos iniciales cargados correctamente."