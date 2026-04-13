# frozen_string_literal: true

module Api
  module V1
    class MeController < BaseController
      skip_before_action :set_resource

      def show
        render json: {
          status: { code: 200, message: 'Current user retrieved successfully.' },
          data: CurrentUserSerializer.new(current_user).serializable_hash
        }, status: :ok
      end

      def update
        if current_user.update(me_params)
          render json: {
            status: { code: 200, message: 'Profile updated successfully.' },
            data: CurrentUserSerializer.new(current_user.reload).serializable_hash
          }, status: :ok
        else
          render json: {
            status: { message: "Profile couldn't be updated. #{current_user.errors.full_messages.to_sentence}" }
          }, status: :unprocessable_entity
        end
      end

      private

      def me_params
        params.permit(:first_name, :last_name, :phone, :profile_image_url, :date_of_birth)
      end
    end
  end
end
