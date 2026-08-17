# frozen_string_literal: true

module NewsIngestion
  class IngestionManager
    SYSTEM_USER_EMAIL = 'bot@flews.app'
    SYSTEM_USER_NAME = 'Flews Curador'

    COMMUNITY_CONFIG = {
      'tecnologia' => [
        { type: :hacker_news, options: { query: 'AI OR software OR tech', min_points: 70, min_comments: 15 } },
        { type: :reddit, options: { subreddit: 'technology', min_score: 120, min_comments: 25 } },
        { type: :reddit, options: { subreddit: 'artificial', min_score: 80, min_comments: 15 } },
        { type: :rss, options: { feed_url: 'https://techcrunch.com/feed/', source_name: 'TechCrunch', limit: 8 } }
      ],
      'ciencia' => [
        { type: :reddit, options: { subreddit: 'science', min_score: 150, min_comments: 30 } },
        { type: :rss, options: { feed_url: 'https://phys.org/rss-feed/', source_name: 'Phys.org Science', limit: 8 } }
      ],
      'salud' => [
        { type: :reddit, options: { subreddit: 'health', min_score: 90, min_comments: 20 } },
        { type: :reddit, options: { subreddit: 'medicine', min_score: 60, min_comments: 15 } },
        { type: :rss, options: { feed_url: 'https://rss.medicalnewstoday.com/featurednews.xml', source_name: 'Medical News Today', limit: 8 } }
      ],
      'gastronomia' => [
        { type: :reddit, options: { subreddit: 'foodscience', min_score: 50, min_comments: 10 } },
        { type: :reddit, options: { subreddit: 'AskCulinary', min_score: 80, min_comments: 20 } },
        { type: :rss, options: { feed_url: 'https://www.eater.com/rss/index.xml', source_name: 'Eater Gastronomy', limit: 8 } }
      ],
      'deportes' => [
        { type: :reddit, options: { subreddit: 'sports', min_score: 100, min_comments: 20 } },
        { type: :rss, options: { feed_url: 'http://feeds.bbci.co.uk/sport/rss.xml', source_name: 'BBC Sport', limit: 8 } }
      ],
      'ciberseguridad' => [
        { type: :reddit, options: { subreddit: 'netsec', min_score: 50, min_comments: 10 } },
        { type: :rss, options: { feed_url: 'https://feeds.feedburner.com/TheHackersNews', source_name: 'The Hacker News', limit: 8 } }
      ],
      'negocios' => [
        { type: :hacker_news, options: { query: 'startup OR business OR market', min_points: 60, min_comments: 12 } }
      ]
    }.freeze

    def self.run
      new.run
    end

    def run
      system_user = find_or_create_system_user
      total_created = 0
      summary = {}

      COMMUNITY_CONFIG.each do |slug, source_definitions|
        community = Community.find_by(slug: slug)
        next unless community

        community_created = 0

        source_definitions.each do |src_def|
          adapter = build_adapter(src_def[:type], src_def[:options])
          next unless adapter

          raw_items = adapter.fetch_trending
          raw_items.each do |item|
            # Deduplicación: Comprobar por título similar o URL en contenido
            existing = Post.where('title ILIKE ?', "%#{item[:title].first(40)}%").exists?
            next if existing

            curated_attrs = Curators::HeuristicCurator.curate(item)
            next if curated_attrs.nil?

            post = Post.new(
              title: curated_attrs[:title],
              content: curated_attrs[:content],
              published_at: curated_attrs[:published_at],
              post_type: curated_attrs[:post_type],
              status: curated_attrs[:status],
              user: system_user,
              community: community
            )

            if post.save
              community_created += 1
              total_created += 1
            end
          end
        end

        summary[slug] = community_created
      end

      Rails.logger.info("[NewsIngestion::IngestionManager] Ingesta completada. Total posts nuevos: #{total_created}. Resumen: #{summary}")
      { total_created: total_created, summary: summary }
    end

    private

    def find_or_create_system_user
      User.find_or_create_by!(email: SYSTEM_USER_EMAIL) do |u|
        u.name = SYSTEM_USER_NAME
      end
    end

    def build_adapter(type, options)
      case type
      when :hacker_news
        Sources::HackerNewsSource.new(options)
      when :reddit
        Sources::RedditSource.new(options)
      when :rss
        Sources::RssFeedSource.new(options)
      else
        nil
      end
    end
  end
end
