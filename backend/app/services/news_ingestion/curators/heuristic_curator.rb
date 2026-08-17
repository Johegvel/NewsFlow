# frozen_string_literal: true

module NewsIngestion
  module Curators
    class HeuristicCurator
      CLICKBAIT_PATTERNS = [
        /you won't believe/i,
        /no vas a creer/i,
        /esta razón te sorprenderá/i,
        /mira lo que pasó/i,
        /unbelievable/i,
        /shocking/i,
        /click here/i
      ].freeze

      def self.curate(raw_item)
        title = raw_item[:title].to_s.strip
        content = raw_item[:content].to_s.strip
        source_name = raw_item[:source_name] || 'Fuente externa'
        score = raw_item[:score].to_i
        comments = raw_item[:comments_count].to_i
        url = raw_item[:url].to_s.strip

        # 1. Filtro de clickbait
        return nil if is_clickbait?(title)

        # 2. Resumen y formato editorial Flews
        editorial_content = build_editorial_content(content, source_name, score, comments, url)

        {
          title: title.truncate(180),
          content: editorial_content,
          published_at: raw_item[:published_at] || Time.current,
          post_type: :opinion,
          status: :published
        }
      end

      def self.is_clickbait?(text)
        CLICKBAIT_PATTERNS.any? { |pattern| text =~ pattern }
      end

      def self.build_editorial_content(raw_content, source_name, score, comments, url)
        # Limpieza de markdown sobrante o espacios repetidos
        cleaned = raw_content.gsub(/\s+/, ' ').strip

        badge = if score > 0
                  "📊 Relevancia: #{score} puntos de comunidad (#{source_name})"
                else
                  "📰 Fuente: #{source_name}"
                end

        summary_body = if cleaned.length > 50
                         cleaned.truncate(500)
                       else
                         "Noticia destacada en #{source_name}. Para profundizar en el contexto completo y las fuentes originales, consulta el enlace adjunto."
                       end

        "#{summary_body}\n\n• #{badge}\n• Enlace original: #{url}"
      end
    end
  end
end
