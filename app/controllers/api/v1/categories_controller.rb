module Api
  module V1
    class CategoriesController < BaseController
      skip_before_action :authenticate_user!

      private

      def resource_params
        params.require(:category).permit(
          :name, :slug, :description, :icon_url, :parent_id,
          :suggested_hourly_rate, :is_active, :sort_order
        )
      end

      def apply_filters(resources)
        resources = resources.active unless params[:include_inactive] == 'true'
        resources = resources.root_categories if params[:root_only] == 'true'
        resources = resources.where(parent_id: params[:parent_id]) if params[:parent_id].present?
        resources = resources.ordered
        resources
      end
    end
  end
end
