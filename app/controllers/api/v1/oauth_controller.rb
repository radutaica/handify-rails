# frozen_string_literal: true

module Api
  module V1
    class OauthController < ApplicationController
      skip_before_action :authenticate_user!, raise: false

      # POST /api/v1/auth/oauth
      def create
        provider = params[:provider]
        token = params[:token]

        unless %w[google_oauth2 apple].include?(provider)
          return render json: { error: "Unsupported provider" }, status: :unprocessable_entity
        end

        user = User.from_omniauth(
          provider: provider,
          uid: params[:uid] || extract_uid(provider, token),
          email: params[:email],
          first_name: params[:first_name],
          last_name: params[:last_name],
          profile_image_url: params[:profile_image_url]
        )

        if user.persisted?
          token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
          render json: {
            success: true,
            jwt: token,
            user: {
              id: user.id,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name,
              user_type: user.user_type,
              profile_image_url: user.profile_image_url
            }
          }, status: :ok
        else
          render json: { error: "Could not authenticate user", errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def extract_uid(provider, token)
        # In production, verify the token with the provider
        # For now, use the token as a fallback UID
        case provider
        when "google_oauth2"
          # Would verify with Google's tokeninfo endpoint
          params[:email]
        when "apple"
          # Would verify Apple identity token
          params[:email]
        end
      end
    end
  end
end
