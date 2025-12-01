# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_signed_out_user, only: :destroy

  # Prevent session writes in API-only mode
  def create
    self.resource = warden.authenticate!(auth_options)
    # JWT token is handled by devise-jwt automatically
    respond_with(resource)
  end

  def destroy
    # Authenticate user from JWT token first
    if user_signed_in?
      # JWT token revocation is handled by devise-jwt automatically
      respond_to_on_destroy
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, _opts = {})
    # Generate JWT token manually using the same mechanism as devise-jwt
    token = generate_jwt_token(resource)
    
    render json: {
      status: { code: 200, message: 'Logged in successfully.' },
      data: UserSerializer.new(resource).serializable_hash,
      token: token
    }, status: :ok
  end

  def generate_jwt_token(user)
    # Use the same encoder that devise-jwt uses internally
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  rescue StandardError => e
    Rails.logger.error "Failed to generate JWT token: #{e.message}"
    # Fallback to manual token generation
    payload = { sub: user.id.to_s, scp: 'user', jti: SecureRandom.uuid }
    secret = Rails.application.credentials.devise_jwt_secret_key || Rails.application.secret_key_base
    JWT.encode(payload, secret, 'HS256')
  end

  def respond_to_on_destroy
    render json: {
      status: 200,
      message: 'Logged out successfully.'
    }, status: :ok
  end
end

