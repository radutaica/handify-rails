# frozen_string_literal: true

class TaskerProfileSerializer
  def initialize(profile)
    @profile = profile
  end

  def serializable_hash
    user = @profile.user

    {
      id: @profile.id,
      user_id: user.id,
      user_name: "#{user.first_name} #{user.last_name}",
      user_first_name: user.first_name,
      user_last_name: user.last_name,
      user_avatar_url: user.profile_image_url,
      bio: @profile.bio,
      hourly_rate: @profile.hourly_rate,
      experience_years: @profile.experience_years,
      avg_rating: @profile.avg_rating,
      total_tasks_completed: @profile.total_tasks_completed,
      total_reviews: user.received_reviews.count,
      is_active: @profile.is_active,
      is_verified: @profile.background_check_status == 'approved',
      allows_instant_booking: @profile.allows_instant_booking,
      response_rate: @profile.response_rate,
      categories: @profile.categories.map { |c| { id: c.id, name: c.name, slug: c.slug } },
      created_at: @profile.created_at,
      updated_at: @profile.updated_at
    }
  end

  def self.serialize_collection(profiles)
    profiles.map { |profile| new(profile).serializable_hash }
  end
end
