module Api
  module V1
    class UserProfilesController < BaseController
      def complete
        profile_params = params.require(:profileData).permit(
          :photo_url, :user_type
        )

        # Map photo_url to profile_image_url
        update_params = {}
        update_params[:profile_image_url] = profile_params[:photo_url] if profile_params[:photo_url].present?
        update_params[:user_type] = profile_params[:user_type] if profile_params[:user_type].present?

        if update_params.empty? || current_user.update(update_params)
          render json: {
            status: { code: 200, message: 'Profile updated successfully.' },
            data: UserSerializer.new(current_user).serializable_hash
          }, status: :ok
        else
          render json: {
            status: { message: "Profile couldn't be updated. #{current_user.errors.full_messages.to_sentence}" }
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
