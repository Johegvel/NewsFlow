require "test_helper"

module NewsIngestion
  module Sources
    class RssFeedSourceTest < ActiveSupport::TestCase
      class TestRssFeedSource < RssFeedSource
        def initialize(xml, options)
          @xml = xml
          super(options)
        end

        private

        def get_xml(*)
          @xml
        end
      end

      test "convierte un RSS válido al formato común de ingesta" do
        xml = <<~XML
          <?xml version="1.0" encoding="UTF-8" ?>
          <rss version="2.0">
            <channel>
              <title>Fuente de prueba</title>
              <item>
                <title>Avance científico verificable</title>
                <link>https://example.com/avance</link>
                <description><![CDATA[<p>Descripción <strong>sin etiquetas</strong>.</p>]]></description>
                <pubDate>#{1.hour.ago.rfc2822}</pubDate>
              </item>
            </channel>
          </rss>
        XML
        source = TestRssFeedSource.new(xml,
          feed_url: "https://example.com/feed.xml",
          source_name: "Fuente de prueba",
          limit: 1
        )

        items = source.fetch_trending

        assert_equal 1, items.size
        assert_equal "Avance científico verificable", items.first[:title]
        assert_equal "Descripción sin etiquetas.", items.first[:content]
        assert_equal "https://example.com/avance", items.first[:url]
      end
    end
  end
end
