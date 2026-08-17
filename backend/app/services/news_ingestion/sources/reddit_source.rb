# frozen_string_literal: true

module NewsIngestion
  module Sources
    class RedditSource < BaseSource
      DEFAULT_MIN_SCORE = 100
      DEFAULT_MIN_COMMENTS = 20

      def fetch_trending
        subreddit = options[:subreddit] || 'technology'
        min_score = options[:min_score] || DEFAULT_MIN_SCORE
        min_comments = options[:min_comments] || DEFAULT_MIN_COMMENTS

        url = "https://www.reddit.com/r/#{subreddit}/top.json?t=day&limit=25"
        data = get_json(url)

        return [] unless data && data.dig('data', 'children').is_a?(Array)

        results = []
        data['data']['children'].each do |child|
          post_data = child['data'] || {}
          next if post_data['is_video'] == true || post_data['over_18'] == true

          score = post_data['score'].to_i
          num_comments = post_data['num_comments'].to_i

          # Filtro de relevancia e interacción
          next if score < min_score || num_comments < min_comments

          title = post_data['title']
          next if title.blank?

          article_url = post_data['url'].presence || "https://reddit.com#{post_data['permalink']}"
          created_utc = post_data['created_utc'].to_i
          published_at = Time.at(created_utc).utc rescue Time.current

          raw_text = post_data['selftext'].presence || "Tendencia en r/#{subreddit} con #{score} puntos de aprobación y #{num_comments} comentarios activos. Fuente original: #{article_url}"

          results << {
            title: title.strip,
            content: raw_text.strip,
            url: article_url,
            score: score,
            comments_count: num_comments,
            published_at: published_at,
            source_name: "Reddit (r/#{subreddit})"
          }
        end

        results
      end
    end
  end
end
