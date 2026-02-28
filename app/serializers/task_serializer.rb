# frozen_string_literal: true

class TaskSerializer
  def initialize(task)
    @task = task
  end

  def serializable_hash
    {
      id: @task.id,
      title: @task.title,
      description: @task.description,
      status: @task.status,
      urgency: @task.urgency,
      pricing_type: @task.pricing_type,
      booking_type: @task.booking_type,
      budget_min: @task.budget_min,
      budget_max: @task.budget_max,
      fixed_price: @task.fixed_price,
      hourly_budget: @task.hourly_budget,
      estimated_hours: @task.estimated_hours,
      task_date: @task.task_date,
      task_time: @task.task_time,
      is_flexible_timing: @task.is_flexible_timing,
      requirements: @task.requirements,
      category: serialize_category,
      address: serialize_address,
      customer: serialize_customer,
      assigned_tasker: serialize_assigned_tasker,
      bids_count: @task.bids.size,
      assigned_at: @task.assigned_at,
      completed_at: @task.completed_at,
      cancelled_at: @task.cancelled_at,
      cancellation_reason: @task.cancellation_reason,
      created_at: @task.created_at,
      updated_at: @task.updated_at
    }
  end

  def self.serialize_collection(tasks)
    tasks.map { |task| new(task).serializable_hash }
  end

  private

  def serialize_category
    return nil unless @task.category

    {
      id: @task.category.id,
      name: @task.category.name,
      slug: @task.category.slug
    }
  end

  def serialize_address
    return nil unless @task.address

    {
      id: @task.address.id,
      street_address: @task.address.street_address,
      city: @task.address.city,
      county: @task.address.county,
      postal_code: @task.address.postal_code,
      full_address: @task.address.full_address
    }
  end

  def serialize_customer
    return nil unless @task.customer

    {
      id: @task.customer.id,
      first_name: @task.customer.first_name,
      last_name: @task.customer.last_name,
      profile_image_url: @task.customer.profile_image_url
    }
  end

  def serialize_assigned_tasker
    return nil unless @task.assigned_tasker

    tasker = @task.assigned_tasker
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
