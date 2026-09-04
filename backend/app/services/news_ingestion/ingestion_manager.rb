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
        { type: :rss, options: { feed_url: "https://www.xataka.com/feedburner.xml", source_name: "Xataka", limit: 8 } },
        { type: :rss, options: { feed_url: "https://www.genbeta.com/feedburner.xml", source_name: "Genbeta", limit: 8 } },
        { type: :rss, options: { feed_url: "https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/section/tecnologia/portada", source_name: "El País Tecnología", limit: 8 } }
      ],
      "ciencia" => [
        { type: :rss, options: { feed_url: "https://www.agenciasinc.es/rss/view/all", source_name: "Agencia SINC", limit: 8 } },
        { type: :rss, options: { feed_url: "https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/section/ciencia/portada", source_name: "El País Ciencia", limit: 8 } }
      ],
      "salud" => [
        { type: :rss, options: { feed_url: "https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/section/salud-y-bienestar/portada", source_name: "El País Salud", limit: 8 } },
        { type: :rss, options: { feed_url: "https://cuidateplus.marca.com/rss/portada.xml", source_name: "CuídatePlus", limit: 8 } }
      ],
      "gastronomia" => [
        { type: :rss, options: { feed_url: "https://www.directoalpaladar.com/feedburner.xml", source_name: "Directo al Paladar", limit: 8 } },
        { type: :rss, options: { feed_url: "https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/section/gastronomia/portada", source_name: "El País Gastronomía", limit: 8 } }
      ],
      "deportes" => [
        { type: :rss, options: { feed_url: "https://e00-marca.uecdn.es/rss/portada.xml", source_name: "Marca", limit: 8 } },
        { type: :rss, options: { feed_url: "https://as.com/rss/tags/ultimas_noticias.xml", source_name: "Diario AS", limit: 8 } }
      ],
      "ciberseguridad" => [
        { type: :rss, options: { feed_url: "https://unaaldia.hispasec.com/feed", source_name: "Una al Día (Hispasec)", limit: 8 } },
        { type: :rss, options: { feed_url: "https://www.genbeta.com/categoria/seguridad/rss2.xml", source_name: "Genbeta Seguridad", limit: 8 } }
      ],
      "negocios" => [
        { type: :rss, options: { feed_url: "https://feeds.elpais.com/mrss-s/pages/ep/site/cincodias.elpais.com/portada", source_name: "Cinco Días", limit: 8 } },
        { type: :rss, options: { feed_url: "https://www.eleconomista.es/rss/rss-portada.php", source_name: "El Economista", limit: 8 } }
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
      saved_post_ids = SavedPost.select(:post_id)

      # 1. Noticias guardadas por usuarios: NO se destruyen para mantenerlas atemporales en su cuenta;
      # simplemente se ocultan del feed público si aún estuviesen visibles.
      Post.where(user: system_user)
          .where(id: saved_post_ids)
          .where("published_at < ? OR (published_at IS NULL AND created_at < ?)", cutoff, cutoff)
          .where.not(status: :hidden)
          .update_all(status: :hidden)

      # 2. Noticias no guardadas por nadie con más de 24 horas: se eliminan
      expired_news = Post.where(user: system_user)
                         .where.not(id: saved_post_ids)
                         .where("published_at < ? OR (published_at IS NULL AND created_at < ?)", cutoff, cutoff)
      deleted_news_count = expired_news.count
      expired_news.destroy_all

      # 3. Críticas con más de 24 horas de publicación: expiran al igual que las noticias
      critique_enum_val = Post.post_types[:critique]
      expired_critiques = Post.where(post_type: critique_enum_val)
                              .where("created_at < ?", cutoff)
      deleted_critiques_count = expired_critiques.count
      expired_critiques.destroy_all

      total_purged = deleted_news_count + deleted_critiques_count
      Rails.logger.info("[NewsIngestion::IngestionManager] Limpieza sincronizada: #{deleted_news_count} noticias y #{deleted_critiques_count} críticas eliminadas (antigüedad > 24h).")
      total_purged
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
