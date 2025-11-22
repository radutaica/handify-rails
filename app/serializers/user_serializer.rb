# frozen_string_literal: true

class UserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    {
      id: @user.id,
      email: @user.email,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end
end

