# frozen_string_literal: true

require 'securerandom'

puts 'Cargando datos iniciales de Flews...'

community_definitions = [
  [ 'tecnologia', 'Tecnología', 'Tecnología', 'Noticias de última hora sobre software, hardware e inteligencia artificial.' ],
  [ 'ciencia', 'Ciencia', 'Ciencia', 'Descubrimientos, avances científicos y exploración espacial.' ],
  [ 'salud', 'Salud', 'Salud', 'Investigación médica, bienestar, longevidad y avances en biotecnología.' ],
  [ 'gastronomia', 'Gastronomía', 'Gastronomía', 'Tendencias culinarias, ciencia de los alimentos y alta cocina global.' ],
  [ 'deportes', 'Deportes', 'Deportes', 'Actualidad, análisis y resultados de las principales disciplinas deportivas.' ],
  [ 'ciberseguridad', 'Ciberseguridad', 'Ciberseguridad', 'Vulnerabilidades críticas, análisis de amenazas e ingeniería de seguridad.' ],
  [ 'negocios', 'Negocios', 'Negocios', 'Startups, finanzas, mercados globales y venture capital.' ]
]

community_definitions.each do |slug, name, topic, description|
  community = Community.find_or_initialize_by(slug: slug)
  community.assign_attributes(name: name, topic: topic, description: description)
  community.save!
end

interest_definitions = [
  [ 'Tecnología & IA', 'tecnologia' ],
  [ 'Deportes', 'deportes' ],
  [ 'Ciencia & Espacio', 'ciencia' ],
  [ 'Salud & Medicina', 'salud' ],
  [ 'Gastronomía', 'gastronomia' ],
  [ 'Ciberseguridad', 'ciberseguridad' ],
  [ 'Negocios & Startups', 'negocios' ]
]

interest_definitions.each do |name, slug|
  interest = Interest.find_or_initialize_by(slug: slug)
  interest.name = name
  interest.save!
end

bot = User.find_or_initialize_by(email: 'bot@flews.app')
bot.name = 'Flews Curador'
configured_bot_password = ENV['FLEWS_BOT_PASSWORD'].presence
if configured_bot_password || bot.new_record? || bot.password_digest.blank?
  bot_password = configured_bot_password || SecureRandom.base64(48)
  bot.password = bot_password
  bot.password_confirmation = bot_password
end
bot.save!

load_demo_data = !Rails.env.production? ||
                 ActiveModel::Type::Boolean.new.cast(ENV.fetch('LOAD_DEMO_DATA', false))

if load_demo_data
  load Rails.root.join('db/seeds/demo_data.rb')
else
  puts 'Datos base cargados: usuario curador, 7 comunidades y 7 intereses.'
end
