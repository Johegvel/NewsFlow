module Api
  module V1
    class ReportsController < ApplicationController
      before_action :authenticate_user!, only: [:index ,:create, :update]

      def index
        reports = if params[:post_id].present?
                    Post.find(params[:post_id]).reports
                  else
                    Report.all
                  end

        reports = reports.includes(:user, :post)
                         .order(status: :asc, created_at: :desc)

        render json: reports.map { |report| report_json(report) }
      end

      def create
        post = Post.find(params[:post_id])
        report = post.reports.new(report_params)
        report.user = current_user

        if report.save
          render json: report, status: :created
        else
          render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        report = Report.find(params[:id])

        if report.update(
          status: update_params[:status],
          reviewed_at: Time.current
        )
          report.post.update(status: :hidden) if report.action_taken?

          render json: report_json(report)
        else
          render json: {
            errors: report.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def report_params
        params.require(:report).permit(:reason)
      end

      def update_params
        params.require(:report).permit(:status)
      end

      def report_json(report)
        {
          id: report.id,
          reason: report.reason,
          status: report.status,
          reviewed_at: report.reviewed_at,
          created_at: report.created_at,
          post: {
            id: report.post.id,
            title: report.post.title
          },
          user: {
            id: report.user.id,
            name: report.user.name
          }
        }
      end
    end
  end
end