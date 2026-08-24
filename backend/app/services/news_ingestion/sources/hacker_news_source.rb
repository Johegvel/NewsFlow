# frozen_string_literal: true

module NewsIngestion
  module Sources
    class HackerNewsSource < BaseSource
      DEFAULT_MIN_POINTS = 60
      DEFAULT_MIN_COMMENTS = 15

      def fetch_trending
        query = options[:query]
        min_points = options[:min_points] || DEFAULT_MIN_POINTS
        min_comments = options[:min_comments] || DEFAULT_MIN_COMMENTS
        max_age_days = options[:max_age_days] || 1
        cutoff = max_age_days.days.ago.to_i

        query_params = {
          tags: "story",
          numericFilters: "points>=#{min_points},created_at_i>=#{cutoff}",
          hitsPerPage: 20
        }
        query_params[:query] = query if query.present?

        url = "https://hn.algolia.com/api/v1/search?#{URI.encode_www_form(query_params)}"

        data = get_json(url)
        return [] unless data && data["hits"].is_a?(Array)

        results = []
        data["hits"].each do |hit|
          points = hit["points"].to_i
          num_comments = hit["num_comments"].to_i

          # Filtro estricto de señal social
          next if points < min_points || num_comments < min_comments

          title = hit["title"]
          next if title.blank?

          article_url = hit["url"].presence || "https://news.ycombinator.com/item?id=#{hit['objectID']}"
          published_at = Time.zone.parse(hit["created_at"]) rescue Time.current

          # Extraer texto de la historia o resumen informativo
          content = hit["story_text"].presence || "Noticia destacada en la comunidad tecnológica con #{points} votos y #{num_comments} comentarios en debate abierto. Enlace directo: #{article_url}"

          results << {
            title: title.strip,
            content: content.strip,
            url: article_url,
            score: points,
            comments_count: num_comments,
            published_at: published_at,
            source_name: "Hacker News"
          }
        end

        results
      end
    end
  end
end
