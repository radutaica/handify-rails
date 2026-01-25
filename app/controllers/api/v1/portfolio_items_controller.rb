module Api
  module V1
    class PortfolioItemsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      private

      def resource_params
        params.require(:portfolio_item).permit(
          :title, :description, :category_id, :task_id, :is_featured,
          images: []
        )
      end

      def apply_filters(resources)
        resources = resources.where(tasker_id: params[:tasker_id]) if params[:tasker_id].present?
        resources = resources.where(category_id: params[:category_id]) if params[:category_id].present?
        resources = resources.featured if params[:featured_only] == 'true'
        resources
      end
    end
  end
end
