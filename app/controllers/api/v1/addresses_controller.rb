module Api
  module V1
    class AddressesController < BaseController
      before_action :ensure_owner, only: [:show, :update, :destroy]

      def index
        addresses = current_user.addresses
        render json: addresses, status: :ok
      end

      def create
        address = current_user.addresses.new(resource_params)

        if address.save
          render json: address, status: :created
        else
          render json: { errors: address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:address).permit(
          :label, :street_address, :city, :county, :postal_code, :country,
          :latitude, :longitude, :is_default
        )
      end

      def ensure_owner
        unless @resource.user_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end
