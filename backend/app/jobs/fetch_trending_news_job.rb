# frozen_string_literal: true

class FetchTrendingNewsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info('[FetchTrendingNewsJob] Iniciando ingesta programada de noticias...')
    result = NewsIngestion::IngestionManager.run
    Rails.logger.info("[FetchTrendingNewsJob] Ingesta finalizada: #{result}")
    result
  end
end
