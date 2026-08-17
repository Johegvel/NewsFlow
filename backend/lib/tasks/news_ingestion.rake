# frozen_string_literal: true

namespace :news do
  desc 'Extrae noticias virales y de alta relevancia desde Hacker News, Reddit y RSS sin costo'
  task fetch_trending: :environment do
    puts '=================================================='
    puts '🚀 Flews: Iniciando Ingesta de Noticias Curadas...'
    puts '=================================================='

    result = NewsIngestion::IngestionManager.run

    puts '=================================================='
    puts "✅ Ingesta Completada!"
    puts "Total publicaciones nuevas creadas: #{result[:total_created]}"
    puts "Desglose por comunidad:"
    result[:summary].each do |community, count|
      puts "  • #{community.capitalize}: #{count} noticias"
    end
    puts '=================================================='
  end
end
