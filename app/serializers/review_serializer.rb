# frozen_string_literal: true

class ReviewSerializer
  def initialize(review)
    @review = review
  end

  def serializable_hash
    {
      id: @review.id,
      task_id: @review.task_id,
      reviewer_id: @review.reviewer_id,
      reviewee_id: @review.reviewee_id,
      reviewer_name: @review.reviewer.first_name,
      reviewer_last_name: @review.reviewer.last_name,
      reviewer_image_url: @review.reviewer.profile_image_url,
      task_title: @review.task&.title,
      rating: @review.rating,
      comment: @review.comment,
      review_type: @review.review_type,
      is_public: @review.is_public,
      tags: @review.tags,
      created_at: @review.created_at,
      updated_at: @review.updated_at
    }
  end

  def self.serialize_collection(reviews)
    reviews.map { |review| new(review).serializable_hash }
  end
end
