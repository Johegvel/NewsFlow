# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module NewsIngestion
  module Sources
    class BaseSource
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
        uri = URI.parse(url_str)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.read_timeout = 10
        http.open_timeout = 5

        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = 'FlewsBot/1.0 (Curated News Ingestor; contact@flews.app)'
        headers.each { |k, v| request[k] = v }

        response = http.request(request)
        return nil unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      rescue StandardError => e
        Rails.logger.error("[NewsIngestion::BaseSource] Error al consultar #{url_str}: #{e.message}")
        nil
      end

      def get_xml(url_str)
        uri = URI.parse(url_str)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.read_timeout = 10
        http.open_timeout = 5

        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = 'FlewsBot/1.0 (Curated News Ingestor)'

        response = http.request(request)
        return nil unless response.is_a?(Net::HTTPSuccess)

        response.body
      rescue StandardError => e
        Rails.logger.error("[NewsIngestion::BaseSource] Error al consultar RSS #{url_str}: #{e.message}")
        nil
      end
    end
  end
end
