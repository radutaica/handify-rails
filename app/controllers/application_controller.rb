class ApplicationController < ActionController::API
  before_action :authenticate_user!, unless: :devise_controller?

  # Prevent session usage in API-only mode
  def session
    @null_session ||= NullSession.new
  end

  private

  def authenticate_user!
    unless user_signed_in?
      render json: {
        status: { code: 401, message: 'You need to sign in or sign up before continuing.' }
      }, status: :unauthorized
    end
  end

  # Null object pattern for session in API-only mode
  class NullSession
    def [](_key)
      nil
    end

    def []=(_key, _value)
      # Do nothing
    end

    def delete(_key)
      nil
    end

    def clear
      # Do nothing
    end

    def to_hash
      {}
    end

    def empty?
      true
    end

    def keys
      []
    end

    def values
      []
    end

    def destroy
      # Do nothing
    end

    def enabled?
      false
    end
  end
end
