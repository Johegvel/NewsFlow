# frozen_string_literal: true

require 'rss'

module NewsIngestion
  module Sources
    class RssFeedSource < BaseSource
      def fetch_trending
        feed_url = options[:feed_url]
        source_label = options[:source_name] || 'RSS Feed'
        limit = options[:limit] || 15

        return [] if feed_url.blank?

        xml_content = get_xml(feed_url)
        return [] if xml_content.blank?

        results = []
        begin
          rss = RSS::Parser.parse(xml_content, false)
          items = rss.items || []

          items.first(limit).each do |item|
            title = item.title.is_a?(String) ? item.title : item.title&.content
            next if title.blank?

            link = if item.respond_to?(:link) && item.link.is_a?(String)
                     item.link
                   elsif item.respond_to?(:link) && item.link.respond_to?(:href)
                     item.link.href
                   else
                     ''
                   end

            description = if item.respond_to?(:description) && item.description.present?
                            item.description.to_s
                          elsif item.respond_to?(:summary) && item.summary.present?
                            item.summary.to_s
                          elsif item.respond_to?(:content_encoded) && item.content_encoded.present?
                            item.content_encoded.to_s
                          else
                            title
                          end

            published_at = if item.respond_to?(:pubDate) && item.pubDate.present?
                             item.pubDate
                           elsif item.respond_to?(:updated) && item.updated.present?
                             item.updated.content
                           else
                             Time.current
                           end

            parsed_date = Time.zone.parse(published_at.to_s) rescue Time.current
            # Filtrar noticias de más de 24 horas
            next if parsed_date && parsed_date < 24.hours.ago

            # Limpiar etiquetas HTML básicas de la descripción
            cleaned_content = description.gsub(/<\/?[^>]*>/, '').gsub(/\s+/, ' ').strip

            results << {
              title: title.strip,
              content: cleaned_content.truncate(600),
              url: link.strip,
              score: 75,
              comments_count: 0,
              published_at: parsed_date || Time.current,
              source_name: source_label
            }
          end
        rescue StandardError => e
          Rails.logger.error("[RssFeedSource] Error parseando feed #{feed_url}: #{e.message}")
        end

        results
      end
    end
  end
end
