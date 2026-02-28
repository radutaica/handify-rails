module Api
  module V1
    class TaskerProfilesController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      def index
        resources = TaskerProfile.includes(:user, :categories)
        resources = apply_filters(resources)
        resources = apply_sorting(resources)

        total = resources.count
        resources = apply_pagination(resources)

        profiles_data = if distance_filter_active?
          lat = params[:lat].to_f
          lng = params[:lng].to_f
          resources.map do |profile|
            address = profile.user.addresses.default_addresses.first || profile.user.addresses.first
            distance = address&.distance_to_coordinates(lat, lng)
            TaskerProfileSerializer.new(profile, distance_km: distance).serializable_hash
          end
        else
          TaskerProfileSerializer.serialize_collection(resources)
        end

        render json: {
          data: profiles_data,
          meta: {
            total: total,
            page: (params[:page] || 1).to_i,
            per_page: [params[:per_page].to_i, 100].min.clamp(1, 100)
          }
        }, status: :ok
      end

      def show
        profile = TaskerProfile.includes(:user, :categories).find(params[:id])
        render json: TaskerProfileSerializer.new(profile).serializable_hash, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'TaskerProfile not found' }, status: :not_found
      end

      # POST /api/v1/tasker_profiles/onboarding
      def onboarding
        service = TaskerProfiles::OnboardingService.new(current_user, onboarding_params)
        result = service.call

        if result.success?
          render json: service.tasker_profile, status: :created
        else
          render json: { errors: service.errors }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:tasker_profile).permit(
          :bio, :hourly_rate, :allows_instant_booking, :instant_booking_buffer_hours,
          :experience_years, :is_active,
          availability: {}, skills: []
        )
      end

      def onboarding_params
        params.require(:tasker_profile).permit(
          :bio, :hourly_rate, :allows_instant_booking, :instant_booking_buffer_hours,
          :experience_years, :is_active,
          availability: {}, skills: [], category_ids: [],
          address: [
            :street_address, :city, :county, :postal_code, :country,
            :latitude, :longitude, :is_default
          ]
        )
      end

      def apply_filters(resources)
        resources = resources.active if params[:active_only] == 'true'
        resources = resources.verified if params[:verified_only] == 'true'
        resources = resources.instant_booking_available if params[:instant_booking] == 'true'
        resources = resources.with_high_rating if params[:high_rated] == 'true'
        resources = resources.by_category(params[:category_id]) if params[:category_id].present?
        resources = resources.with_min_rating(params[:min_rating].to_f) if params[:min_rating].present?
        resources = resources.with_hourly_rate_range(params[:min_rate], params[:max_rate]) if params[:min_rate].present? || params[:max_rate].present?
        resources = resources.search(params[:q]) if params[:q].present?

        if distance_filter_active?
          nearby_user_ids = Address.near_coordinates(
            params[:lat].to_f,
            params[:lng].to_f,
            params[:radius].to_f
          ).pluck(:user_id)
          resources = resources.joins(:user).where(users: { id: nearby_user_ids })
        end

        resources
      end

      def distance_filter_active?
        params[:lat].present? && params[:lng].present?
      end

      def apply_sorting(resources)
        case params[:sort]
        when 'completed_tasks'
          resources.order(total_tasks_completed: :desc)
        when 'hourly_rate'
          resources.order(hourly_rate: :asc)
        else
          resources.order(avg_rating: :desc)
        end
      end
    end
  end
end
