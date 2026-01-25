# frozen_string_literal: true

class UserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    {
      id: @user.id,
      email: @user.email,
      first_name: @user.first_name,
      last_name: @user.last_name,
      user_type: @user.user_type,
      phone: @user.phone,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end
end

