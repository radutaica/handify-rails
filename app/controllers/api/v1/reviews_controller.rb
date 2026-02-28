module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      def index
        resources = Review.includes(:reviewer, :task)
        resources = apply_filters(resources)
        resources = resources.recent
        resources = apply_pagination(resources)

        render json: ReviewSerializer.serialize_collection(resources), status: :ok
      end

      def show
        review = Review.includes(:reviewer, :task).find(params[:id])
        render json: ReviewSerializer.new(review).serializable_hash, status: :ok
      end

      def create
        task = Task.find(params[:review][:task_id])

        unless task.status == 'completed'
          render json: { error: 'Recenziile pot fi lasate doar pentru sarcini finalizate' }, status: :unprocessable_entity and return
        end

        review = Review.new(resource_params)
        review.reviewer = current_user

        # Auto-set review_type based on the reviewer's role in the task
        if task.customer_id == current_user.id
          review.review_type = 'customer_to_tasker'
          review.reviewee_id = task.assigned_tasker_id
        elsif task.assigned_tasker_id == current_user.id
          review.review_type = 'tasker_to_customer'
          review.reviewee_id = task.customer_id
        else
          render json: { error: 'Nu esti autorizat sa lasi o recenzie pentru aceasta sarcina' }, status: :forbidden and return
        end

        if review.save
          render json: ReviewSerializer.new(review.reload).serializable_hash, status: :created
        else
          render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:review).permit(
          :task_id, :rating, :comment, :is_public, tags: []
        )
      end

      def apply_filters(resources)
        resources = resources.where(reviewee_id: params[:reviewee_id]) if params[:reviewee_id].present?
        resources = resources.where(reviewer_id: params[:reviewer_id]) if params[:reviewer_id].present?
        resources = resources.where(task_id: params[:task_id]) if params[:task_id].present?
        resources = resources.public_reviews if params[:public_only] == 'true'
        resources = resources.high_rated if params[:high_rated] == 'true'
        resources
      end
    end
  end
end
