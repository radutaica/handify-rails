module Api
  module V1
    class FavoritesController < BaseController
      def index
        favorites = current_user.customer_favorites.includes(:tasker)
        render json: favorites, status: :ok
      end

      def create
        favorite = current_user.customer_favorites.new(tasker_id: params[:tasker_id])

        if favorite.save
          render json: favorite, status: :created
        else
          render json: { errors: favorite.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        favorite = current_user.customer_favorites.find(params[:id])

        if favorite.destroy
          head :no_content
        else
          render json: { errors: favorite.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:favorite).permit(:tasker_id)
      end
    end
  end
end
