module Api
  module V1
    class PreferencesController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: preference_json(preference)
      end

      def update
        if preference.update(preference_params)
          render json: preference_json(preference)
        else
          render json: { errors: preference.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def preference
        @preference ||= current_user.user_preference || current_user.create_user_preference!
      end

      def preference_params
        params.require(:preferences).permit(
          :reading_history_enabled,
          :personalization_enabled,
          :morning_digest_enabled,
          :curation_alerts_enabled
        )
      end

      def preference_json(record)
        {
          reading_history_enabled: record.reading_history_enabled,
          personalization_enabled: record.personalization_enabled,
          morning_digest_enabled: record.morning_digest_enabled,
          curation_alerts_enabled: record.curation_alerts_enabled
        }
      end
    end
  end
end
