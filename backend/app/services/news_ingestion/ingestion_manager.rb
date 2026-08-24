# frozen_string_literal: true

require "securerandom"

module NewsIngestion
  class IngestionManager
    SYSTEM_USER_EMAIL = "bot@flews.app"
    SYSTEM_USER_NAME = "Flews Curador"
    MAX_POSTS_PER_SOURCE = 4
    MAX_POSTS_PER_COMMUNITY = 12

    COMMUNITY_CONFIG = {
      "tecnologia" => [
        { type: :hacker_news, options: { query: "AI OR software OR tech", min_points: 70, min_comments: 15 } },
        { type: :rss, options: { feed_url: "https://techcrunch.com/feed/", source_name: "TechCrunch", limit: 8 } }
      ],
      "ciencia" => [
        { type: :rss, options: { feed_url: "https://phys.org/rss-feed/", source_name: "Phys.org Science", limit: 8 } }
      ],
      "salud" => [
        { type: :rss, options: { feed_url: "https://www.niehs.nih.gov/news/newsroom/rssfeed/rss_news.xml", source_name: "NIEHS", limit: 8 } }
      ],
      "gastronomia" => [
        { type: :rss, options: { feed_url: "https://www.eater.com/rss/index.xml", source_name: "Eater Gastronomy", limit: 8 } }
      ],
      "deportes" => [
        { type: :rss, options: { feed_url: "http://feeds.bbci.co.uk/sport/rss.xml", source_name: "BBC Sport", limit: 8 } }
      ],
      "ciberseguridad" => [
        { type: :rss, options: { feed_url: "https://feeds.feedburner.com/TheHackersNews", source_name: "The Hacker News", limit: 8 } }
      ],
      "negocios" => [
        { type: :hacker_news, options: { query: "startup OR business OR market", min_points: 60, min_comments: 12 } },
        { type: :rss, options: { feed_url: "https://techcrunch.com/category/startups/feed/", source_name: "TechCrunch Startups", limit: 8 } }
      ]
    }.freeze

    def self.run
      new.run
    end

    def run
      system_user = find_or_create_system_user
      deleted_count = purge_expired_news(system_user)
      total_created = 0
      summary = {}

      COMMUNITY_CONFIG.each do |slug, source_definitions|
        community = Community.find_by(slug: slug)
        next unless community

        community_created = 0

        source_definitions.each do |src_def|
          break if community_created >= MAX_POSTS_PER_COMMUNITY

          adapter = build_adapter(src_def[:type], src_def[:options])
          next unless adapter

          raw_items = adapter.fetch_trending
          source_created = 0
          raw_items.each do |item|
            break if source_created >= MAX_POSTS_PER_SOURCE || community_created >= MAX_POSTS_PER_COMMUNITY

            curated_attrs = Curators::HeuristicCurator.curate(item)
            next if curated_attrs.nil?
            next if duplicate?(curated_attrs[:title], item[:url])

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
              source_created += 1
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

    def purge_expired_news(system_user)
      cutoff = 24.hours.ago
      expired = Post.where(user: system_user)
                    .where("published_at < ? OR (published_at IS NULL AND created_at < ?)", cutoff, cutoff)
      count = expired.count
      expired.destroy_all
      Rails.logger.info("[NewsIngestion::IngestionManager] Limpieza de noticias expiradas: #{count} posts eliminados (antigüedad > 24h).")
      count
    end

    def find_or_create_system_user
      user = User.find_or_initialize_by(email: SYSTEM_USER_EMAIL)
      user.name = SYSTEM_USER_NAME

      if user.new_record? || user.password_digest.blank?
        password = SecureRandom.base64(48)
        user.password = password
        user.password_confirmation = password
      end

      user.save!
      user
    end

    def duplicate?(title, url)
      normalized_title = title.to_s.strip.downcase
      return true if Post.where("LOWER(title) = ?", normalized_title).exists?

      normalized_url = url.to_s.strip
      return false if normalized_url.blank?

      escaped_url = ActiveRecord::Base.sanitize_sql_like(normalized_url)
      Post.where("content LIKE ?", "%#{escaped_url}%").exists?
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
