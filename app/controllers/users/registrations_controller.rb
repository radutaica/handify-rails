# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # Override create to prevent session usage
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      sign_in(resource)  # Trigger Warden auth flow so devise-jwt generates the JWT token
      respond_with(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with(resource)
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :user_type, :phone)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: UserSerializer.new(resource).serializable_hash
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end

