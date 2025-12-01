# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # Override create to prevent session usage
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      # JWT token is handled by devise-jwt automatically
      respond_with(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with(resource)
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name,)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      # Generate JWT token manually using the same mechanism as devise-jwt
      # No need to call sign_in since we're in API mode and sessions are disabled
      token = generate_jwt_token(resource)
      
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: UserSerializer.new(resource).serializable_hash,
        token: token
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
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
end

