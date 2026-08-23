# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module NewsIngestion
  module Sources
    class BaseSource
      MAX_REDIRECTS = 3

      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      # Debe retornar un Array de Hashes con:
      # {
      #   title: String,
      #   content: String,
      #   url: String,
      #   score: Integer,
      #   comments_count: Integer,
      #   published_at: Time,
      #   source_name: String
      # }
      def fetch_trending
        raise NotImplementedError, "#{self.class} debe implementar #fetch_trending"
      end

      protected

      def get_json(url_str, headers = {})
        response = get_response(url_str, headers)
        return nil unless response

        JSON.parse(response.body)
      rescue StandardError => e
        Rails.logger.error("[NewsIngestion::BaseSource] Error al consultar #{url_str}: #{e.message}")
        nil
      end

      def get_xml(url_str)
        response = get_response(url_str)
        response&.body
      rescue StandardError => e
        Rails.logger.error("[NewsIngestion::BaseSource] Error al consultar RSS #{url_str}: #{e.message}")
        nil
      end

      private

      def get_response(url_str, headers = {}, redirects_remaining = MAX_REDIRECTS)
        uri = URI.parse(url_str)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.read_timeout = 10
        http.open_timeout = 5

        request = Net::HTTP::Get.new(uri.request_uri)
        request["User-Agent"] = "FlewsBot/1.0 (Curated News Ingestor; contact@flews.app)"
        headers.each { |key, value| request[key] = value }

        response = http.request(request)
        return response if response.is_a?(Net::HTTPSuccess)

        if response.is_a?(Net::HTTPRedirection) && redirects_remaining.positive?
          location = response["location"]
          return nil if location.blank?

          redirect_url = URI.join(uri.to_s, location).to_s
          return get_response(redirect_url, headers, redirects_remaining - 1)
        end

        Rails.logger.warn(
          "[NewsIngestion::BaseSource] Respuesta HTTP #{response.code} al consultar #{url_str}"
        )

        nil
      end
    end
  end
end
