module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      private

      def resource_params
        params.require(:review).permit(
          :task_id, :reviewee_id, :rating, :comment, :review_type,
          :is_public, tags: []
        )
      end

      def apply_filters(resources)
        resources = resources.where(reviewee_id: params[:reviewee_id]) if params[:reviewee_id].present?
        resources = resources.where(reviewer_id: params[:reviewer_id]) if params[:reviewer_id].present?
        resources = resources.where(task_id: params[:task_id]) if params[:task_id].present?
        resources = resources.public_reviews if params[:public_only] == 'true'
        resources = resources.high_rated if params[:high_rated] == 'true'
        resources
      end
    end
  end
end
