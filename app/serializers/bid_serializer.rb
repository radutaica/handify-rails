# frozen_string_literal: true

class BidSerializer
  def initialize(bid)
    @bid = bid
  end

  def serializable_hash
    {
      id: @bid.id,
      task_id: @bid.task_id,
      amount: @bid.amount,
      estimated_hours: @bid.estimated_hours,
      proposed_date: @bid.proposed_date,
      proposed_time: @bid.proposed_time,
      message: @bid.message,
      status: @bid.status,
      tasker: serialize_tasker,
      created_at: @bid.created_at,
      updated_at: @bid.updated_at
    }
  end

  def self.serialize_collection(bids)
    bids.map { |bid| new(bid).serializable_hash }
  end

  private

  def serialize_tasker
    return nil unless @bid.tasker

    tasker = @bid.tasker
    profile = tasker.tasker_profile

    {
      id: tasker.id,
      first_name: tasker.first_name,
      last_name: tasker.last_name,
      profile_image_url: tasker.profile_image_url,
      avg_rating: profile&.avg_rating,
      total_tasks_completed: profile&.total_tasks_completed
    }
  end
end
