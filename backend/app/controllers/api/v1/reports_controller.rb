module Api
  module V1
    class ReportsController < ApplicationController
      before_action :set_post

      def index
        reports = @post.reports
                       .includes(:user)
                       .order(created_at: :desc)

        render json: reports.map { |report| report_json(report) }
      end

      def create
        report = @post.reports.new(report_params)

        if report.save
          render json: report_json(report), status: :created
        else
          render json: {
            errors: report.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def report_params
        params.require(:report).permit(:user_id, :reason)
      end

      def report_json(report)
        {
          id: report.id,
          reason: report.reason,
          status: report.status,
          reviewed_at: report.reviewed_at,
          created_at: report.created_at,
          user: {
            id: report.user.id,
            name: report.user.name
          },
          post_id: report.post_id
        }
      end
    end
  end
end