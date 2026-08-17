# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

puts "Cargando datos iniciales de Flews..."

johan = User.find_or_create_by!(email: "johan@newsflow.com") do |user|
  user.name = "Johan Veloz"
end

xavier = User.find_or_create_by!(email: "xavier@newsflow.com") do |user|
  user.name = "Xavier Camacho"
end

bot = User.find_or_create_by!(email: "bot@flews.app") do |user|
  user.name = "Flews Curador"
end

tecnologia = Community.find_or_create_by!(slug: "tecnologia") do |community|
  community.name = "Tecnología"
  community.description = "Noticias de última hora sobre software, hardware e inteligencia artificial."
  community.topic = "Tecnología"
end

ciencia = Community.find_or_create_by!(slug: "ciencia") do |community|
  community.name = "Ciencia"
  community.description = "Descubrimientos, avances científicos y exploración espacial."
  community.topic = "Ciencia"
end

salud = Community.find_or_create_by!(slug: "salud") do |community|
  community.name = "Salud"
  community.description = "Investigación médica, bienestar, longevidad y avances en biotecnología."
  community.topic = "Salud"
end

gastronomia = Community.find_or_create_by!(slug: "gastronomia") do |community|
  community.name = "Gastronomía"
  community.description = "Tendencias culinarias, ciencia de los alimentos y alta cocina global."
  community.topic = "Gastronomía"
end

deportes = Community.find_or_create_by!(slug: "deportes") do |community|
  community.name = "Deportes"
  community.description = "Actualidad, análisis y resultados de las principales disciplinas deportivas."
  community.topic = "Deportes"
end

ciberseguridad = Community.find_or_create_by!(slug: "ciberseguridad") do |community|
  community.name = "Ciberseguridad"
  community.description = "Vulnerabilidades críticas, análisis de amenazas e ingeniería de seguridad."
  community.topic = "Ciberseguridad"
end

negocios = Community.find_or_create_by!(slug: "negocios") do |community|
  community.name = "Negocios"
  community.description = "Startups, finanzas, mercados globales y venture capital."
  community.topic = "Negocios"
end

Post.find_or_create_by!(
  title: "La inteligencia artificial continúa transformando la tecnología"
) do |post|
  post.content = "Las nuevas herramientas de inteligencia artificial están cambiando la forma de trabajar y aprender.\n\n• 📊 Relevancia: Alta\n• Fuente: Flews Editorial"
  post.user = johan
  post.community = tecnologia
  post.post_type = :discussion
  post.status = :published
  post.published_at = Time.current
end

Post.find_or_create_by!(
  title: "Anthropic presenta nuevo módulo de análisis y auditoría de ciberseguridad"
) do |post|
  post.content = "Anthropic ha anunciado nuevas herramientas diseñadas para asistir a equipos de seguridad informática en la detección proactiva de vectores de ataque y vulnerabilidades en código fuente.\n\n• 📊 Relevancia: 340 puntos de comunidad (Hacker News)\n• Fuente: Hacker News"
  post.user = bot
  post.community = ciberseguridad
  post.post_type = :opinion
  post.status = :published
  post.published_at = Time.current
end

Post.find_or_create_by!(
  title: "Nuevo ensayo clínico valida terapia dirigida con ARNm contra tumores resistentes"
) do |post|
  post.content = "Resultados publicados en fase avanzada demuestran una reducción significativa en recurrencia tumoral mediante vacunas personalizadas de ARNm combinadas con inmunoterapia.\n\n• 📊 Relevancia: 195 puntos (Medical News Today / Lancet)\n• Fuente: Medical News Today"
  post.user = bot
  post.community = salud
  post.post_type = :opinion
  post.status = :published
  post.published_at = Time.current
end

Post.find_or_create_by!(
  title: "La fermentación de precisión revoluciona la textura en gastronomía sostenible"
) do |post|
  post.content = "Chefs de vanguardia y científicos de alimentos presentan técnicas de microfermentación que replican perfiles moleculares complejos de quesos añejos y grasas nobles sin impacto ganadero.\n\n• 📊 Relevancia: 140 puntos (Eater / FoodScience)\n• Fuente: Eater Gastronomy"
  post.user = bot
  post.community = gastronomia
  post.post_type = :opinion
  post.status = :published
  post.published_at = Time.current
end

Post.find_or_create_by!(
  title: "Nuevo avance en computación cuántica reduce tasas de error"
) do |post|
  post.content = "Investigadores logran un hito experimental al corregir errores de cúbits lógicos en tiempo real, aproximando la computación cuántica tolerante a fallos.\n\n• 📊 Relevancia: 280 puntos (Phys.org)\n• Fuente: Phys.org Science"
  post.user = bot
  post.community = ciencia
  post.post_type = :opinion
  post.status = :published
  post.published_at = Time.current
end

puts "Datos iniciales de Flews cargados correctamente con Salud y Gastronomía."