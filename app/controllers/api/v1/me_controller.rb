# frozen_string_literal: true

module Api
  module V1
    class MeController < BaseController
      def show
        render json: {
          status: { code: 200, message: 'Current user retrieved successfully.' },
          data: CurrentUserSerializer.new(current_user).serializable_hash
        }, status: :ok
      end
    end
  end
end
