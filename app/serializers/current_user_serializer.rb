# frozen_string_literal: true

class CurrentUserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    base_hash.merge(tasker_data)
  end

  private

  def base_hash
    {
      id: @user.id,
      email: @user.email,
      first_name: @user.first_name,
      last_name: @user.last_name,
      user_type: @user.user_type,
      phone: @user.phone,
      profile_image_url: @user.profile_image_url,
      id_verified: @user.id_verified,
      status: @user.status,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end

  def tasker_data
    return {} unless @user.tasker_profile.present?
    { tasker_profile: TaskerProfileSerializer.new(@user.tasker_profile).serializable_hash }
  end
end
